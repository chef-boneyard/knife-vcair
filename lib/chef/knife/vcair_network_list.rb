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

require 'chef/knife/cloud/list_resource_command'
require 'chef/knife/vchs_helpers'
require 'chef/knife/cloud/vchs_service_options'

class Chef
  class Knife
    class Cloud
      class VchsNetworkList < ResourceListCommand
        include VchsHelpers
        include VchsServiceOptions

        banner "knife vchs network list (options)"

        def query_resource
          @service.connection.organizations.get_by_name(Chef::Config[:knife][:vchs_org]).networks
        end

        def before_exec_command
          @columns_with_info = [
            {:label => 'Name', :key => 'name'},
            {:label => 'Gateway', :key => 'gateway'},
            {:label => 'IP Range Start', :key => 'ip_ranges', :value_callback => method(:start_address) },
            {:label => 'End', :key => 'ip_ranges', :value_callback => method(:end_address) },
            {:label => 'Description', :key => 'description'}
          ]
          @sort_by_field = "name"
        end

        def start_address(ranges)
          ranges[0][:start_address]
        end

        def end_address(ranges)
          ranges[0][:end_address]
        end
      end
    end
  end
end
