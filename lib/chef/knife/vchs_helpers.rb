#
# Author:: 
# Copyright:: 
#

require 'chef/knife/cloud/vchs_service_options'

class Chef
  class Knife
    class Cloud
      module VchsHelpers

        # TODO - Define helper methods used across your commands 

        def create_service_instance
          VchsService.new
        end

        def validate!
          super(:vchs_username, :vchs_password, :vchs_api_url)
        end
      end
    end
  end
end
