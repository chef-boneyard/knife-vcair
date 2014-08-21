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
          # TODO: validate required params
          # TODO: make this work with multiple VDCs
          # TODO make this work with multiple networks
          # TODO: allow specifying network name rather than searching for Routed
          # TODO: find by catalog item ID
          # TODO: add option to search just public and/or private catalogs
          # TODO: Add NAT rules optionally?

          ## NOTE: ubuntu seems to not use customizaton (script nor setting password)
          ## NOTE: Ubuntu system default to not allowing ssh w/ password even if known
          #template = public_catalog.catalog_items.get_by_name(
          #  'Ubuntu Server 12.04 LTS (amd64 20140619)'

          # These are helper functions
          instanciate
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

        def before_exec_command
          @create_options = {
            :server_def => {
              :name => config[:chef_node_name],
              :image_ref => config_value(:image),
              
            },
            :server_create_timeout => config_value(:server_create_timeout)
          }
          
          if config_value(:vcair_custom_script)
            @create_options[:server_def].merge!({
                            customization_script: config_value(:vcair_custom_script)})
          end
          if config_value(:vcair_cpus)
            @create_options[:server_def].merge!({:cpus => config_value(:vcair_cpus)})
          end
          if config_value(:vcair_memory)
            @create_options[:server_def].merge!({:memory => config_value(:vcair_memory)})
          end

          Chef::Log.debug("Create server params - server_def = #{@create_options[:server_def]}")
          @columns_with_info = []
          super
        end

        # Setup the floating ip after server creation.
        def after_exec_command
          # Any action you want to perform post VM creation in your cloud.
          # Example say assigning floating IP to the newly created VM.
          # Make calls to "service" object if you need any information for cloud,
          #    example service.connection.addresses
          # Make call to "server" object if you want set properties on newly created VM,
          #   example server.associate_address(floating_address)
          super
        end

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
          super
          errors = []
          
          # TODO - Add your validation here for any create server parameters and populate errors [] with error message strings.

          # errors << "your error message" if some_param_undefined

          error_message = ""
          raise CloudExceptions::ValidationError, error_message if errors.each{|e| ui.error(e); error_message = "#{error_message} #{e}."}.any?
        end
      end
    end
  end
end
