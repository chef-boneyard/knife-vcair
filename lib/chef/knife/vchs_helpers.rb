#
# Author:: 
# Copyright:: 
#

require 'chef/knife/cloud/vchs_service_options'
require 'pry'

class Chef
  class Knife
    class Cloud
      module VchsHelpers

        # TODO - Define helper methods used across your commands 

        def create_service_instance
          VchsService.new
        end
        
        def org
          @org ||= @service.connection.organizations.get_by_name(
                                                                 locate_config_value(:vchs_org))
        end

        def vdc
          vdc_name = locate_config_value(:vchs_org)
          @vdc ||= vdc_name.nil? ? org.vdcs.first : org.vdcs.get_by_name(vdc_name)
        end
        
        def net
          @net ||= org.networks.find { |n| n if n.name.match("routed$")  }
        end

        def template
          @template ||= org.catalogs.map{|cat| cat.catalog_items.get_by_name(locate_config_value(:image))}.compact.first
        end
        
        def vapp
          @vapp ||= vdc.vapps.get_by_name(locate_config_value(:chef_node_name))
        end
        
        def vm
          @vm ||= vapp.vms.find {|v| v.vapp_name == locate_config_value(:chef_node_name) }
        end

        def network_config
          @network_config ||= vapp.network_config.find { |n| n if n[:networkName].match("routed$") }
        end
        
        def instanciate
          @instancate ||= template.instantiate(locate_config_value(:chef_node_name),vdc_id: vdc.id, network_id: net.id, description: 'description')
        end
        
        def get_id(value)
          value['id']
        end
        
        # Setup the floating ip after server creation.
        def after_exec_command
          # Any action you want to perform post VM creation in your cloud.
          # Example say assigning floating IP to the newly created VM.
          # Make calls to "service" object if you need any information for cloud, example service.connection.addresses
          # Make call to "server" object if you want set properties on newly created VM, example server.associate_address(floating_address)

          super
        end

        def before_bootstrap
          super
          # TODO - Set the IP address that should be used for connection with the newly created VM. This IP address is used for bootstrapping the VM and should be accessible from knife workstation.

          # your logic goes here to set bootstrap_ip_address...

          Chef::Log.debug("Bootstrap IP Address: #{bootstrap_ip_address}")
          if bootstrap_ip_address.nil?
            error_message = "No IP address available for bootstrapping."
            ui.error(error_message)
            raise CloudExceptions::BootstrapError, error_message
          end
          config[:bootstrap_ip_address] = bootstrap_ip_address
        end

        def update_network
          ## TODO: allow user to specify network to connect to (see above net used)
          # Define network connection for vm based on existing routed network
          # network_config = vapp_new.network_config.find { |n| n if n[:networkName].match("routed$") }
          nc = vapp.network_config.find { |n| n if n[:networkName].match("routed$") }
          networks_config = [nc]
#           networks_config = [network_config]

          # networks_config = vapp_new.network_config
          section = {PrimaryNetworkConnectionIndex: 0}
          section[:NetworkConnection] = networks_config.compact.each_with_index.map do |network, i|
            connection = {
              network: network[:networkName],
              needsCustomization: true,
              NetworkConnectionIndex: i,
              IsConnected: true
            }
            ip_address      = network[:ip_address]
            #allocation_mode = network[:allocation_mode]
            #allocation_mode = 'manual' if ip_address
            #allocation_mode = 'dhcp' unless %w{dhcp manual pool}.include?(allocation_mode)
            #allocation_mode = 'POOL'

            ## TODO: support config options for allocation mode
            allocation_mode = 'pool'
            connection[:IpAddressAllocationMode] = allocation_mode.upcase
            connection[:IpAddress] = ip_address if ip_address
            #connection[:Dns1] = dns1 if dns1
            connection
          end

          ## attach the network to the vm
          nc_task = @service.connection.put_network_connection_system_section_vapp(
            vm.id,section).body
          @service.connection.process_task(nc_task)
        end

        def update_customization
          ## Initialization before first power on.
          c=vm.customization
          c.admin_password_auto = false # default auto
          # c.admin_password_auto = true # auto
          #
          ## TODO: take password from config/options
          #c.admin_password = ENV['VCLOUD_VM_ADMIN_PASSWORD']
          #  bundle exec knife vchs server create  -VV
# ERROR: You must provide either Identity file or SSH Password.
# DEBUG:  You must provide either Identity file or SSH Password..
          
          c.admin_password = locate_config_value(:ssh_password) # SecureRandom.base64(15)
          c.reset_password_required = false

          ## TODO: make customizaton_script pull from config/command options if available
          #c.customization_script = "sed -ibak 's/^PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config"
          #c.script = "#!/bin/sh\ntouch /tmp/wedidit\nsed -ibak 's/^PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config"
          # system name via hostname
          #c.computer_name = 'DEV-' + Time.now.to_s.gsub(" ","-").gsub(":","-")
          c.computer_name = locate_config_value(:chef_node_name).gsub(/\W/,"-")
          c.enabled = true

          c.save
        end

        def bootstrap_ip_address
          vm.reload
          vm.ip_address
        end

        def validate!
          # FIXME: validation is broken atm
          return true
          super(:vchs_username, :vchs_password, :vchs_api_url)
        end
      end
    end
  end
end
