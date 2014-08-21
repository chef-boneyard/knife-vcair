#
# Author:: 
# Copyright:: 
#

require 'pry'
require 'chef/knife/cloud/server/create_command'
require 'chef/knife/vcair_helpers'
require 'chef/knife/cloud/vcair_server_create_options'
require 'chef/knife/cloud/vcair_service'
require 'chef/knife/cloud/vcair_service_options'
require 'chef/knife/cloud/exceptions'

class Chef
  class Knife
    class Cloud
      class VcairServerCreate < ServerCreateCommand
        include VcairHelpers
        include VcairServiceOptions
        include VcairServerCreateOptions

        deps do
          require 'chef/knife/winrm_base'
          require 'winrm'
          require 'em-winrm'
          require 'chef/json_compat'
          require 'chef/knife/bootstrap'
          require 'chef/knife/bootstrap_windows_winrm'
          require 'chef/knife/core/windows_bootstrap_context'
          require 'chef/knife/winrm'
          Chef::Knife::Bootstrap.load_deps
        end

        banner "knife vcair server create (options)"

        def execute_command
          instantiate
          update_customization
          if config_value(:vcpus)
            vm.cpus = config_value(:vcpus)
          end
          if config_value(:memory)
            vm.memory = config_value(:memory)
          end
          update_network
          vm.power_on
        end

        def set_image_os_type
          # TODO: Pull Template VM OS Type
          # config[:image_os_type] = (ami.platform == 'windows') ?  'windows' :  'linux'
        end

        # def before_exec_command
        #   @create_options = {
        #     :server_def => {
        #       :name => config[:chef_node_name],
        #       :image_ref => config_value(:image),
              
        #     },
        #     :server_create_timeout => config_value(:server_create_timeout)
        #   }
          
        #   if config_value(:vcair_custom_script)
        #     @create_options[:server_def].merge!({
        #                     customization_script: config_value(:vcair_custom_script)})
        #   end
        #   if config_value(:vcair_cpus)
        #     @create_options[:server_def].merge!({:cpus => config_value(:vcair_cpus)})
        #   end
        #   if config_value(:vcair_memory)
        #     @create_options[:server_def].merge!({:memory => config_value(:vcair_memory)})
        #   end

        #   Chef::Log.debug("Create server params - server_def = #{@create_options[:server_def]}")
        #   @columns_with_info = []
        #   super
        # end

        # Setup the floating ip after server creation.
        # def after_exec_command
          # TODO: Add NAT rules optionally?

          # Any action you want to perform post VM creation in your cloud.
          # Example say assigning floating IP to the newly created VM.
          # Make calls to "service" object if you need any information for cloud,
          #    example service.connection.addresses
          # Make call to "server" object if you want set properties on newly created VM,
          #   example server.associate_address(floating_address)
          # super
      #end

        def before_bootstrap
          super
          vm.reload
          Chef::Log.debug("Bootstrap IP Address: #{bootstrap_ip_address}")
          Chef::Log.info("SSH Password: #{vm.customization.admin_password}")
          Chef::Config[:ssh_password] = vm.customization.admin_password
          if bootstrap_ip_address.nil?
            error_message = "No IP address available for bootstrapping."
            ui.error(error_message)
            raise CloudExceptions::BootstrapError, error_message
          end
          config[:bootstrap_ip_address] = bootstrap_ip_address
        end

        def validate_params!
          # TODO: validate required params
          super
          errors = []
          case config_value(:bootstrap_protocol)
          when 'winrm'
            password = config_value(:winrm_password)
            errors << "WinRM requires a password on Vcair" unless password
            batch_file = config_value(:customization_script)
            if File.exists? batch_file
              batch_contents = open(batch_file).read
              if not contents.grep /${password}/
                errors << "WinRM customization script must set password"
              end
            else
              errors << """
WinRM requires a customization_script on Vcair
The batch file should setup winrm and set the password
An example is available at:
https://raw.githubusercontent.com/vulk/knife-vchs/server-create/install-winrm-vcair-example.bat
"""
            end
          when 'ssh'
            errors << "SSH requires a password on Vcair" unless config_value(:ssh_password)
          end

          # errors << "your error message" if some_param_undefined
          # TODO: Error out if windows users don't provide a password
          # AND maybe even force a batch file and check that the password
          # is in it
          error_message = "We are very sorry that you will be unable to continue"
          raise CloudExceptions::ValidationError, error_message if errors.each{|e| ui.error(e); error_message = "#{error_message} #{e}."}.any?
        end

        private

        def instantiate
          node_name = config_value(:chef_node_name)
          template.instantiate(
                               node_name,
                               vdc_id: vdc.id,
                               network_id: net.id,
                               description: "id:#{node_name}")
        end
        
        def update_customization
          ## Initialization before first power on.
          c=vm.customization
          
          if config_value(:customization_script)
            c.script = open(config_value(:customization_script)).read
          end
          
          password = case config_value(:bootstrap_protocol)
                     when 'winrm'
                       config_value(:winrm_password)
                     when 'ssh'
                       config_value(:ssh_password)
                     end
          if password
            c.admin_password =  password 
            c.admin_password_auto = false
            c.reset_password_required = false
          else
            # Password will be autogenerated
            c.admin_password_auto=true
            # API will force password resets when auto is enabled
            c.reset_password_required = true
          end
          
          # TODO: Add support for admin_auto_logon to fog
          # c.admin_auto_logon_count = 100
          # c.admin_auto_logon_enabled = true

          # DNS and Windows want AlphaNumeric and dashes for hostnames
          c.computer_name = config_value(:chef_node_name).gsub(/\W/,"-")
          c.enabled = true
          c.save
        end

        def update_network
          ## TODO: allow user to specify network to connect to (see above net used)
          # Define network connection for vm based on existing routed network
          nc = vapp.network_config.find { |n| n if n[:networkName].match("routed$") }
          networks_config = [nc]
          section = {PrimaryNetworkConnectionIndex: 0}
          section[:NetworkConnection] = networks_config.compact.each_with_index.map do |network, i|
            connection = {
              network: network[:networkName],
              needsCustomization: true,
              NetworkConnectionIndex: i,
              IsConnected: true
            }
            ip_address      = network[:ip_address]
            ## TODO: support config options for allocation mode
            #allocation_mode = network[:allocation_mode]
            #allocation_mode = 'manual' if ip_address
            #allocation_mode = 'dhcp' unless %w{dhcp manual pool}.include?(allocation_mode)
            #allocation_mode = 'POOL'
            #connection[:Dns1] = dns1 if dns1
            allocation_mode = 'pool'
            connection[:IpAddressAllocationMode] = allocation_mode.upcase
            connection[:IpAddress] = ip_address if ip_address
            connection
          end

          ## attach the network to the vm
          nc_task = @service.connection.put_network_connection_system_section_vapp(
            vm.id,section).body
          @service.connection.process_task(nc_task)
        end

        def bootstrap_ip_address
          vm.reload
          vm.ip_address
        end

      end
    end
  end
end
