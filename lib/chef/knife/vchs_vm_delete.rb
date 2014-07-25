#
# Author:: Matt Ray (<matt@getchef.com>)
# Copyright:: Copyright (c) 2014 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/knife/cloud/server/delete_options'
require 'chef/knife/cloud/server/delete_command'
require 'chef/knife/cloud/vchs_service'
require 'chef/knife/cloud/vchs_service_options'
require 'chef/knife/vchs_helpers'

class Chef
  class Knife
    class Cloud
      class VchsVmDelete < ServerDeleteCommand
        include ServerDeleteOptions
        include VchsServiceOptions
        include VchsHelpers

        banner "knife vchs vm delete INSTANCEID [INSTANCEID] (options)"

        def execute_command
          vdc = @service.connection.organizations.get_by_name(Chef::Config[:knife][:vchs_org]).vdcs.first
          # get the vapps or get_by_id?

          # @name_args.each do |server_name|
          #   @service.delete_server(server_name) # FIX THIS COMMAND

          # find the specific vms vms.get_single_vm(vm_id)
          # do we need to write vm.get_by_name, are names unique?
          # it looks like we're just deleting by vAPP... what?
          # do we need to do anything else? power_off?

          #   delete_from_chef(server_name)
          # end
        end

      end
    end
  end
end
