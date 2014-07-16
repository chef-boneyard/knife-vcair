#
# Author:: 
# Copyright:: 
#

require 'chef/knife/cloud/list_resource_command'
require 'chef/knife/vchs_helpers'
require 'chef/knife/cloud/vchs_service_options'

class Chef
  class Knife
    class Cloud
      class VchsFlavorList < ResourceListCommand
        include VchsHelpers
        include VchsServiceOptions

        banner "knife vchs flavor list (options)"

        def before_exec_command
          # Set columns_with_info map
          # TODO - Update the columns info with the keys and callbacks required as per fog object returned for your cloud. Framework looks for 'key' on your flavor object hash returned by fog. If you need the values to be formatted or if your value is another object that needs to be looked up use value_callback.
          # Example:
          @columns_with_info = [
            {:label => 'ID', :key => 'id'},
            {:label => 'Name', :key => 'name'},
            {:label => 'Virtual CPUs', :key => 'vcpus'},
            {:label => 'RAM', :key => 'ram', :value_callback => method(:ram_in_mb)},
            {:label => 'Disk', :key => 'disk', :value_callback => method(:disk_in_gb)}
          ]
        end

        def query_resource
          @service.list_resource_configurations
        end

        # TODO - This is just for example
        def ram_in_mb(ram)
          "#{ram} MB"
        end

        # TODO - This is just for example
        def disk_in_gb(disk)
          "#{disk} GB"
        end

      end
    end
  end
end