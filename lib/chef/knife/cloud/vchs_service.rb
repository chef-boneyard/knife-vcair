#
# Author:: 
# Copyright:: 
#

require 'chef/knife/cloud/fog/service'

class Chef
  class Knife
    class Cloud
      class VchsService < FogService

        def initialize(options = {})
          # TODO - Add cloud specific auth params to be passed to fog connection. See knife-openstack for real life example.
          Chef::Log.debug("vchs_username #{Chef::Config[:knife][:vchs_username]}")
          Chef::Log.debug("vchs_api_url] #{Chef::Config[:knife][:vchs_api_url]}")

          # TODO -build username

          super(options.merge({
                              :auth_params => {
                                :provider => 'vclouddirector',
                                :vcloud_director_username => Chef::Config[:knife][:vchs_username],
                                :vcloud_director_password => Chef::Config[:knife][:vchs_password],
                                :vcloud_director_host => Chef::Config[:knife][:vchs_api_url],
                                :vcloud_director_api_version => '5.6'
                }}))
        end

        def add_api_endpoint
          @auth_params.merge!({:vchs_api_url => Chef::Config[:knife][:vchs_api_url]}) unless Chef::Config[:knife][:api_endpoint].nil?
        end

      end
    end
  end
end
