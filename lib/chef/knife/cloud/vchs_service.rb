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
          super(options.merge({
                              :auth_params => {
                                :provider => 'vchs',
                                :vchs_username => Chef::Config[:knife][:vchs_username],
                                :vchs_api_key => Chef::Config[:knife][:vchs_password],
                                :vchs_auth_url => Chef::Config[:knife][:vchs_auth_url],
                                :vchs_endpoint_type => Chef::Config[:knife][:vchs_endpoint_type],
                                :vchs_tenant => Chef::Config[:knife][:vchs_tenant],
                                :connection_options => {
                                  :ssl_verify_peer => !Chef::Config[:knife][:vchs_insecure]
                                }
                }}))
        end

      end
    end
  end
end
