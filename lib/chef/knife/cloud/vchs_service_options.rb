#
# Author:: 
# Copyright:: 
#

require 'chef/knife/cloud/fog/options'
class Chef
  class Knife
    class Cloud
      module VchsServiceOptions

       def self.included(includer)
          includer.class_eval do
            include FogOptions

            # TODO - define your cloud specific auth options.
            # Example:
            # Vchs Connection params.
            #option :vchs_username,
            #  :short => "-A USERNAME",
            #  :long => "--vchs-username KEY",
            #  :description => "Your Vchs Username",
            #  :proc => Proc.new { |key| Chef::Config[:knife][:vchs_username] = key }
          end
        end
      end
    end
  end
end
