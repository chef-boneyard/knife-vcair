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

require 'chef/knife/cloud/server/create_options'

class Chef
  class Knife
    class Cloud
      module VcairServerCreateOptions

       def self.included(includer)
         includer.class_eval do
           include ServerCreateOptions

           # availble in knife.rb -short
           option :vcair_customization_script,
           :long => "--customization-script SCRIPTFILE",
           :short => "-B SCRIPTFILE",
           :description => "The Bat or Shell script to provision the instance with",
           :default => nil,
           :proc => Proc.new { |o| Chef::Config[:knife][:vcair_customization_script] = o }

           option :vcair_cpus,
           :long => "--cpus CPUS",
           :short => "-C CPUS",
           :description => "Defines the number of vCPUS per VM. Possible values are 1,2,4,8",
           :proc => Proc.new { |o| Chef::Config[:knife][:vcair_cpus] = o }

           option :vcair_memory,
           :long => "--memory MEMORY",
           :short => "-M MEMORY",
           :description => "Defines the number of MB of memory. [512,1024,1536,2048,4096,8192,12288,16384]",
           :proc => Proc.new { |o| Chef::Config[:knife][:vcair_memory] = o }

           option :vcair_net,
           :long => "--vcair-net NETWORKNAME",
           :description => "Your VCAIR NETWORK",
           :default => nil,
           :proc => Proc.new { |key| Chef::Config[:knife][:vcair_net] = key }

            # TODO - Define your cloud specific create server options here. Example.
            # Vcair Server create params.
            # option :private_network,
            #:long => "--vcair-private-network",
            #:description => "Use the private IP for bootstrapping rather than the public IP",
            #:boolean => true,
            #:default => false
            # option :public_ip,
            #:long => "--vcair-public-ip",
            #:description => "Public IP from the avaliable pool to setup SNAT/DNAT for
            #:default => nil

          end
        end
      end
    end
  end
end
