#
# Author:: 
# Copyright:: 
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
          Chef::Log.debug("vcair_api_version #{Chef::Config[:knife][:vcair_api_version]}")

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
              :vcloud_director_api_version => Chef::Config[:knife][:vcair_api_version]
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
