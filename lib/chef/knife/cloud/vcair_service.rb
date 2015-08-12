#
# Author:: "Vulk Wolfpack" <wolfpack@vulk.co>
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

require 'chef/knife/cloud/fog/service'

class Chef
  class Knife
    class Cloud
      class VcairService < FogService

        def initialize(options = {})
          Chef::Log.debug("vcair_username #{Chef::Config[:knife][:vcair_username]}")
          Chef::Log.debug("vcair_org #{Chef::Config[:knife][:vcair_org]}")
          Chef::Log.debug("vcair_api_host #{Chef::Config[:knife][:vcair_api_host]}")
          Chef::Log.debug("vcair_api_path #{Chef::Config[:knife][:vcair_api_path]}")
          Chef::Log.debug("vcair_api_version #{Chef::Config[:knife][:vcair_api_version]}")
          Chef::Log.debug("vcair_show_progress #{Chef::Config[:knife][:vcair_show_progress]}")

          username = [
                      Chef::Config[:knife][:vcair_username],
                      Chef::Config[:knife][:vcair_org]
                      ].join('@')

          super(options.merge({
            :auth_params => {
              :provider => 'vclouddirector',
              :vcloud_director_username => username,
              :vcloud_director_password => Chef::Config[:knife][:vcair_password],
              :vcloud_director_host => Chef::Config[:knife][:vcair_api_host],
              :vcloud_director_api_version => Chef::Config[:knife][:vcair_api_version],
              :vcloud_director_show_progress => false,
              :path => Chef::Config[:knife][:vcair_api_path]
            }
          }))
        end

        def add_api_endpoint
          @auth_params.merge!({:vcair_api_host => Chef::Config[:knife][:vcair_api_host]}) unless Chef::Config[:knife][:api_endpoint].nil?
        end
      end
    end
  end
end
