#
# Author:: 
# Copyright:: 
#

require 'chef/knife/cloud/server/list_command'
require 'chef/knife/vchs_helpers'
require 'chef/knife/cloud/vchs_service_options'
require 'chef/knife/cloud/server/list_options'

class Chef
  class Knife
    class Cloud
      class VchsServerList < ServerListCommand
        include VchsHelpers
        include VchsServiceOptions
        include ServerListOptions

        banner "knife vchs server list (options)"

        def before_exec_command
          # TODO - Update the columns info with the keys and callbacks required as per fog object returned for your cloud. Framework looks for 'key' on your server object hash returned by fog. If you need the values to be formatted or if your value is another object that needs to be looked up use value_callback.

          @columns_with_info = [
            {:label => 'Instance ID', :key => 'id'},
            {:label => 'Name', :key => 'name'},
            {:label => 'Public IP', :key => 'addresses', :value_callback => method(:your_callback)},
            #...
          ]
          super
        end

        # TODO - callback example, this gets a object/value returned by server.addresses
        def your_callback (addresses)
          #...
        end

      end
    end
  end
end
