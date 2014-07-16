#
# Author:: 
# Copyright:: 
#

require 'chef/knife/cloud/list_resource_command'
require 'chef/knife/vchs_helpers'
require 'chef/knife/cloud/vchs_service_options'

class Chef
  class Knife
    class Cloud
      class VchsImageList < ResourceListCommand
        include VchsHelpers
        include VchsServiceOptions

        banner "knife vchs image list (options)"

        # TODO - Add this flag if you plan to support filtering of images.
        #option :disable_filter,
        #  :long => "--disable-filter",
        #  :description => "TODO-Example: Disable filtering of the image list. Currently filters names ending with 'initrd' or 'kernel'",
        #  :boolean => true,
        #  :default => false

        def before_exec_command
          # set resource_filters
          # TODO - If you need resource filtering, setup the resource filter as below.
          #if !config[:disable_filter]
          #  @resource_filters = [{:attribute => 'name', :regex => /initrd$|kernel$|loader$|virtual$|vmlinuz$/}]
          #end

          # TODO - Update the columns info with the keys and callbacks required as per fog object returned for your cloud. Framework looks for 'key' on your image object hash returned by fog. If you need the values to be formatted or if your value is another object that needs to be looked up use value_callback.
          # Example:
          @columns_with_info = [
            {:label => 'ID', :key => 'id'}, 
            {:label => 'Name', :key => 'name'},
            {:label => 'Snapshot', :key => 'metadata', :value_callback => method(:is_image_snapshot)}
          ]
        end

        def query_resource
          @service.list_images
        end

        # TODO - value lookup example from openstack
        def is_image_snapshot(metadata)
          snapshot = 'no'
          metadata.each do |datum|
            if (datum.key == 'image_type') && (datum.value == 'snapshot')
              snapshot = 'yes'
            end
          end
          snapshot
        end

      end
    end
  end
end