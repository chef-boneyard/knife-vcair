#
# Author:: 
# Copyright:: 
#

require 'chef/knife/cloud/server/show_command'
require 'chef/knife/vchs_helpers'
require 'chef/knife/cloud/server/show_options'
require 'chef/knife/cloud/vchs_service'
require 'chef/knife/cloud/vchs_service_options'
require 'chef/knife/cloud/exceptions'

class Chef
  class Knife
    class Cloud
      class VchsServerShow < ServerShowCommand
        include VchsHelpers
        include VchsServiceOptions
        include ServerShowOptions

        banner "knife vchs server show (options)"

        def before_exec_command
          # TODO - Update the columns info with the keys and callbacks required as per fog object returned for your cloud. Framework looks for 'key' on your server object hash returned by fog. If you need the values to be formatted or if your value is another object that needs to be looked up use value_callback.

          @columns_with_info = [
            {:label => 'Instance ID', :key => 'id'},
            {:label => 'Name', :key => 'name'},
            #...
          ]
          super
        end

      end
    end
  end
end
