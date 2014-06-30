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
          # TODO - update these as per your cloud. Validating auth params defined in service options
          super(:vchs_username, :vchs_password, :vchs_auth_url)
        end
      end
    end
  end
end
