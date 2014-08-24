#
# Author:: "Vulk Wolfpack" <wolfpack@vulk.co>
# Copyright:: Chef Inc.
#

require 'chef/knife/cloud/vcair_service_options'

class Chef
  class Knife
    class Cloud
      module VcairHelpers

        def create_service_instance
          VcairService.new
        end
        
        def org
          @org ||= @service.connection.organizations.get_by_name(
                     config_value(:vcair_org))
        end

        def vdc
          if config_value(:vcair_vdc)
            @vdc ||= org.vdcs.get_by_name(config_value(:vcair_vdc))
          else
            @vdc ||= org.vdcs.first
          end
        end
        
        def net
          # TODO make this work with multiple networks
          # TODO: allow specifying network name rather than searching for Routed
          @net ||= org.networks.find { |n| n if n.name.match("routed$") }
        end

        def template
          # TODO: find by catalog item ID and/or NAME
          # TODO: add option to search just public and/or private catalogs
          @template ||= org.catalogs.map do |cat|
            cat.catalog_items.get_by_name(config_value(:image))
          end.compact.first
        end
        
        def vapp
          @vapp ||= vdc.vapps.get_by_name(config_value(:chef_node_name))
        end
        
        def vm
          @vm ||= vapp.vms.find {|v| v.vapp_name == config_value(:chef_node_name)}
        end

        def network_config
          @network_config ||= vapp.network_config.find do |n|
            n if n[:networkName].match("routed$")
          end
        end
        

        def config_value(key)
          key = key.to_sym
          Chef::Config[:knife][key] || config[key]
        end
        
        def get_id(value)
          value['id']
        end

        def msg_pair(label, value, color=:cyan)
          if value && !value.to_s.empty?
            puts "#{ui.color(label, color)}: #{value}"
          end
        end
        
        def validate!(keys=[:vcair_username, :vcair_password, :vcair_api_host, :vcair_org, :vcair_api_version])
          errors = []
          keys.each do |k|
            pretty_key = k.to_s.gsub(/_/, ' ').gsub(/\w+/){ |w| (w =~ /(ssh)/i) ? w.upcase  : w.capitalize }
            if config_value(k).nil?
              errors << "You did not provide a valid '#{pretty_key}' value. Please set knife[:#{k}] in your knife.rb or pass as an option."
            end
          end
          
          if errors.each{|e| ui.error(e)}.any?
            exit 1
          end
        end
        
      end
    end
  end
end
