#
# Author:: 
# Copyright:: 
#

require 'chef/knife/cloud/server/delete_options'
require 'chef/knife/cloud/server/delete_command'
require 'chef/knife/cloud/vchs_service'
require 'chef/knife/cloud/vchs_service_options'
require 'chef/knife/vchs_helpers'

class Chef
  class Knife
    class Cloud
      class VchsServerDelete < ServerDeleteCommand
        include ServerDeleteOptions
        include VchsServiceOptions
        include VchsHelpers

        banner "knife vchs server delete INSTANCEID [INSTANCEID] (options)"

      end
    end
  end
end
