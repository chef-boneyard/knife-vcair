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

require 'chef/knife/cloud/fog/options'

class Chef
  class Knife
    class Cloud
      module VcairServiceOptions

       def self.included(includer)
         includer.class_eval do
           include FogOptions

           # vcair connection params
           option :vcair_api_version,
           :long => "--vcair-api-version VERSION",
           :description => "The VCAIR API version",
           :default => '5.6',
           :proc => Proc.new { |u| Chef::Config[:knife][:vcair_api_version] = u }

           option :vcair_api_host,
           :short => "-U API_HOST",
           :long => "--vcair-api-host HOST",
           :description => "The VCAIR API endpoint",
           :proc => Proc.new { |u| Chef::Config[:knife][:vcair_api_host] = u }
           
           option :vcair_org,
           :short => "-O ORG",
           :long => "--vcair-org ORG",
           :description => "The VCAIR ORG",
           :proc => Proc.new { |u| Chef::Config[:knife][:vcair_org] = u }

           option :vcair_username,
           :short => "-A USERNAME",
           :long => "--vcair-username USERNAME",
           :description => "Your VCAIR username",
           :proc => Proc.new { |username| Chef::Config[:knife][:vcair_username] = username }
           
           option :vcair_password,
           :short => "-K PASSWORD",
           :long => "--vcair-password PASSWORD",
           :description => "Your VCAIR password",
           :proc => Proc.new { |key| Chef::Config[:knife][:vcair_password] = key }
           
           option :vcair_vdc,
           :long => "--vcair-vdc VDCNAME",
           :description => "Your VCAIR VDC",
           :default => nil,
           :proc => Proc.new { |key| Chef::Config[:knife][:vcair_vdc] = key }
           
           option :vcair_show_progress,
           :long => "--vcair-show-progress BOOL",
           :description => "Show VCAIR API Progress",
           :default => false
           
          end
        end
      end
    end
  end
end
