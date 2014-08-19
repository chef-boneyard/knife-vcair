#
# Author:: 
# Copyright:: 
#

require 'chef/knife/cloud/server/create_options'

class Chef
  class Knife
    class Cloud
      module VchsServerCreateOptions

       def self.included(includer)
         includer.class_eval do
           include ServerCreateOptions
           
           option :customization_script,
           :long => "--customization-script BAT_OR_SHELL",
           :description => "The Bat or Shell script to provision the instance with",
           :default => nil

           option :vcpus,
           :long => "--vcpus VCPUS",
           :description => "Defines the number of vCPUS per VM. Possible values are 1,2,4,8",
           :proc => Proc.new { |vcpu| Chef::Config[:knife][:vcpus] = vcpu }

           option :memory,
           :short => "-m MEMORY",
           :long => "--memory MEMORY",
           :description => "Defines the number of MB of memory. Possible values are 512,1024,1536,2048,4096,8192,12288 or 16384.",
           :proc => Proc.new { |memory| Chef::Config[:knife][:memory] = memory }

            # TODO - Define your cloud specific create server options here. Example.
            # Vchs Server create params.
            # option :private_network,
            #:long => "--vchs-private-network",
            #:description => "Use the private IP for bootstrapping rather than the public IP",
            #:boolean => true,
            #:default => false

          end
        end
      end
    end
  end
end
