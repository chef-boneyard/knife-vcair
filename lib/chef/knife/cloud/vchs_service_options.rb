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
            # vCHS connection params
            option :vchs_username,
              :short => "-A USERNAME",
              :long => "--vchs-username USERNAME",
              :description => "Your vCloud Hybrid Service username",
              :proc => Proc.new { |key| Chef::Config[:knife][:vchs_username] = key }

            option :vchs_password,
              :short => "-K SECRET",
              :long => "--vchs-password SECRET",
              :description => "Your vCloud Hybrid Service password",
              :proc => Proc.new { |key| Chef::Config[:knife][:vchs_password] = key }

            option :vchs_api_url,
              :long => "--vchs-api-url URL",
              :description => "Your vCloud Hybrid Service API URL",
              :proc => Proc.new { |key| Chef::Config[:knife][:vchs_api_url] = key }

            option :vchs_org,
              :long => "--vchs-org ORG",
              :description => "Your vCloud Hybrid Service Organization",
              :proc => Proc.new { |key| Chef::Config[:knife][:vchs_org] = key }
          end
        end
      end
    end
  end
end
