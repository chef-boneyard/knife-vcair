#
# Author:: 
# Copyright:: 
#

require 'chef/knife/cloud/server/create_command'
require 'chef/knife/vchs_helpers'
require 'chef/knife/cloud/vchs_server_create_options'
require 'chef/knife/cloud/vchs_service'
require 'chef/knife/cloud/vchs_service_options'
require 'chef/knife/cloud/exceptions'

class Chef
  class Knife
    class Cloud
      class VchsServerCreate < ServerCreateCommand
        include VchsHelpers
        include VchsServerCreateOptions
        include VchsServiceOptions


        banner "knife vchs server create (options)"

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
