#
# Author::
# Copyright::
#

require 'chef/knife/vchs_vm_list'
require 'chef/knife/cloud/vchs_service_options'

class Chef
  class Knife
    class Cloud
      class VchsServerList < VchsVmList
        include VchsServiceOptions

        banner "knife vchs server list (options)"

      end
    end
  end
end
