#
# Author:: 
# Copyright:: 
#

require 'chef/knife/cloud/server/create_command'
require 'chef/knife/vchs_helpers'
require 'chef/knife/vchs_base'
require 'chef/knife/cloud/vchs_server_create_options'
require 'chef/knife/cloud/vchs_service'
require 'chef/knife/cloud/vchs_service_options'
require 'chef/knife/cloud/exceptions'

class Chef
  class Knife
    class Cloud
      class VchsServerCreate < ServerCreateCommand
        include Knife::VchsBase
        include VchsHelpers
        include VchsServerCreateOptions
        include VchsServiceOptions

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

        banner "knife vchs server create (options)"

        def tcp_test_ssh(hostname, port)
          tcp_socket = TCPSocket.new(hostname, port)
          readable = IO.select([tcp_socket], nil, nil, 5)
          if readable
            Chef::Log.debug("sshd accepting connections on #{hostname}, banner is #{tcp_socket.gets}")
            yield
            true
          else
            false
          end
        rescue Errno::ETIMEDOUT
          false
        rescue Errno::EPERM
          false
        rescue Errno::ECONNREFUSED
          sleep 2
          false
        rescue Errno::EHOSTUNREACH
          sleep 2
          false
       rescue Errno::ENETUNREACH
          sleep 2
          false
       rescue Errno::ECONNRESET
          sleep 2
          false
        ensure
          tcp_socket && tcp_socket.close
        end

        def tcp_test_winrm(hostname, port)
          TCPSocket.new(hostname, port)
          yield
          true
        rescue SocketError
          sleep 2
          false
        rescue Errno::ETIMEDOUT
          false
        rescue Errno::EPERM
          false
        rescue Errno::ECONNREFUSED
          sleep 2
          false
        rescue Errno::EHOSTUNREACH
          sleep 2
          false
        rescue Errno::ENETUNREACH
          sleep 2
          false
        end

        def run
          # NOTE: This code is for exploring vchs and not meant to be run as a whole script
          #
          #
          # get secrets
          #require 'dotenv'

          #Dotenv.load unless ENV['VCLOUD_DIRECTOR_USERNAME']

          # initialize vchs with secrets
          uname = locate_config_value(:vchs_username)
          pw = locate_config_value(:vchs_password)
          org = locate_config_value(:vchs_org)
          host = locate_config_value(:vchs_host)
          api_version = locate_config_value(:vchs_api_version)
          conn = Fog::Compute::VcloudDirector.new(
            :vcloud_director_username => uname + '@'+ org,
            :vcloud_director_password => pw,
            :vcloud_director_host => host,
            :vcloud_director_api_version => api_version)

        #  # connect to the virtual data center (vdc)
        #  # get vcd, org, catalog list, network
        #  vdc = conn.organizations.first.vdcs.first
        #  org = conn.organizations.first
        #  public_catalog = conn.organizations.first.catalogs.last
        #  # probably not needed, get this again below
        #  net = conn.organizations.first.networks.last

        #  # create new system (just like a physical system was built for you)
        #  vname = 'vdemo11-' + rand.to_s

        #  ## NOTE: ubuntu seems to not use customizaton (script nor setting password) also no ssh with password
        #  #template = public_catalog.catalog_items.get_by_name('Ubuntu Server 12.04 LTS (amd64 20140619)')
        #  # get catalog (os type)
        #  template = public_catalog.catalog_items.get_by_name('CentOS64-64bit')
        #  # routed nework is the default network
        #  net = conn.organizations.first.networks.find { |n| n if n.name.match("routed$")  }
        #  # create the template/vname
        #  template.instantiate(vname, vdc_id: vdc.id, network_id: net.id, description: vname + ' Desc')
        #  # create new application (might be a set of vms) based on vname
        #  vapp_new = vdc.vapps.get_by_name(vname)
        #  # get a vm instance from the vapp
        #  vm_new = vapp_new.vms.first

        #  # Define network connection for vm based on existing routed network
        #  network_config = vapp_new.network_config.find { |n| n if n[:networkName].match("routed$") }
        #  networks_config = [network_config]

        #  # networks_config = vapp_new.network_config
        #  section = {PrimaryNetworkConnectionIndex: 0}
        #  section[:NetworkConnection] = networks_config.compact.each_with_index.map do |network, i|
        #    connection = {
        #      network: network[:networkName],
        #      needsCustomization: true,
        #      NetworkConnectionIndex: i,
        #      IsConnected: true
        #    }
        #    ip_address      = network[:ip_address]
        #    #allocation_mode = network[:allocation_mode]
        #    #allocation_mode = 'manual' if ip_address
        #    #allocation_mode = 'dhcp' unless %w{dhcp manual pool}.include?(allocation_mode)
        #    #allocation_mode = 'POOL'
        #    allocation_mode = 'pool'
        #    connection[:IpAddressAllocationMode] = allocation_mode.upcase
        #    connection[:IpAddress] = ip_address if ip_address
        #    connection
        #  end

        #  ## attach the network to the vm
        #  nc_task = conn.put_network_connection_system_section_vapp(vm_new.id,section).body
        #  conn.process_task(nc_task)


        #  # TODO: 
        #  #section = "gateway NAT rule here"
        #  #nc_task = conn.post_edge_gateway_configuration(vm_new.id,section).body
        #  #conn.process_task(nc_task)

        #  ## Initialization before first power on.
        #  c=vm_new.customization
        #  c.admin_password_auto = false # auto
        #  # c.admin_password_auto = true # auto
        #  c.admin_password = ENV['VCLOUD_VM_ADMIN_PASSWORD']
        #  c.reset_password_required = false
        #  #c.customization_script = "sed -ibak 's/^PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config"
        #  c.script = "#!/bin/sh\ntouch /tmp/wedidit\nsed -ibak 's/^PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config"
        #  # system name via hostname
        #  c.computer_name = 'DEV-' + Time.now.to_s.gsub(" ","-").gsub(":","-")
        #  c.enabled = true

        #  c.save

        #  # power up box for the first time.
        #  vm_new.power_on

        #  # # Refresh attributes for vm object to look at in IRB
        #  # vm_new.reload

        #  # # Show all the good stuff
        #  # vm_new.network
        #  # vm_new.customization.admin_password
        #  # vm_new.status
        #  # vm_new.ip_address
        #  # vm_new.customization.admin_password
        end

        def before_exec_command
            # setup the create options
            # TODO - update this section to define the server_def that should be passed to fog for creating VM. This will be specific to your cloud.
            # Example:
            @create_options = {
              :server_def => {
                # servers require a name, knife-cloud generates the chef_node_name
                :name => config[:chef_node_name],
                :image_ref => locate_config_value(:image),
                :flavor_ref => locate_config_value(:flavor),
                #...
              },
              :server_create_timeout => locate_config_value(:server_create_timeout)
            }

            @create_options[:server_def].merge!({:user_data => locate_config_value(:user_data)}) if locate_config_value(:user_data)

            Chef::Log.debug("Create server params - server_def = #{@create_options[:server_def]}")

            # TODO - Update the columns info with the keys and callbacks required as per fog object returned for your cloud. Framework looks for 'key' on your image object hash returned by fog. If you need the values to be formatted or if your value is another object that needs to be looked up use value_callback.
            # Example:
            @columns_with_info = [
              {:label => 'Instance ID', :key => 'id'},
              {:label => 'Name', :key => 'name'},
              {:label => 'Public IP', :key => 'addresses', :value_callback => method(:primary_public_ip_address)},
              {:label => 'Private IP', :key => 'addresses', :value_callback => method(:primary_private_ip_address)},
              {:label => 'Flavor', :key => 'flavor', :value_callback => method(:get_id)},
              {:label => 'Image', :key => 'image', :value_callback => method(:get_id)},
              {:label => 'Keypair', :key => 'key_name'},
              {:label => 'State', :key => 'state'}
            ]
            super
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
