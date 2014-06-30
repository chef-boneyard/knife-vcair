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
