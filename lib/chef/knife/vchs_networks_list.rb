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
          begin
          @service.connection.organizations

          rescue Excon::Errors::BadRequest => e
            response = Chef::JSONCompat.from_json(e.response.body)
            ui.fatal("Unknown server error (#{response['badRequest']['code']}): #{response['badRequest']['message']}")
            raise e
          end
        end

      	def list(organizations)
          network_list = [
            ui.color('Name', :bold),
            ui.color('Gateway', :bold),
            ui.color('IP Range Start', :bold),
            ui.color('End', :bold),
            ui.color('Description', :bold),
          ]
          org = organizations.get_by_name(Chef::Config[:knife][:vchs_org])
          networks = org.networks.all
          if networks
            networks.all.sort_by(&:name).each do |network|
              network_list << network.name
              network_list << network.gateway
              network_list << network.ip_ranges[0][:start_address]
              network_list << network.ip_ranges[0][:end_address]
              network_list << network.description
            end
          end
        puts ui.list(network_list, :uneven_columns_across, 5)
        end
      end

    end
  end
end
