#
# Author:: Matt Ray (<matt@getchef.com>)
# Author:: Seth Thomas (<sthomas@getchef.com>)
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

require 'chef/knife/cloud/list_resource_command'
require 'chef/knife/vchs_helpers'
require 'chef/knife/cloud/vchs_service_options'

class Chef
  class Knife
    class Cloud
      class VchsVmList < ResourceListCommand
        include VchsHelpers
        include VchsServiceOptions

        banner "knife vchs vm list (options)"

        def query_resource
          vdc = @service.connection.organizations.get_by_name(Chef::Config[:knife][:vchs_org]).vdcs.first
          vms = []
          vdc.vapps.all.each do |vapp|
            vms << vapp.vms.all
          end
          vms.flatten
        end

        def before_exec_command
          @columns_with_info = [
            {:label => 'vAPP', :key => 'vapp_name'},
            {:label => 'Name', :key => 'name'},
            {:label => 'IP', :key => 'ip_address'},
            {:label => 'CPU', :key => 'cpu'},
            {:label => 'Memory', :key => 'memory'},
            {:label => 'OS', :key => 'operating_system'},
            {:label => 'Owner', :key => 'vapp', :value_callback => method(:owner) },
            {:label => 'Status', :key => 'status'}
          ]
          @sort_by_field = 'vapp_name'
        end

        def owner(vapp)
          vapp.owner[0][:name]
        end

      end
    end
  end
end
