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
          if config_value(:vcair_net_id)
            Chef::Log.debug("Looking up network by ID: #{config_value(:vcair_net_id)}")
            begin
              @net ||= org.networks.get(config_value(:vcair_net_id))
            rescue => e
              raise "Unable to locate network ID #{config_value(:vcair_net_id)} -- #{e.message}"
            end
          elsif config_value(:vcair_net)
            Chef::Log.debug("Looking up network by name: #{config_value(:vcair_net)}")
            @net ||= org.networks.get_by_name(config_value(:vcair_net))
          else
            # Grab first non-isolated (bridged, natRouted) network
            Chef::Log.debug("No network specified, trying to locate one...")
            @net ||= org.networks.find { |n| n if !n.fence_mode.match("isolated") }
          end

          raise "No network found - available networks: #{available_networks.join(', ')}" if @net.nil?

          Chef::Log.debug("Using network #{@net.name} (#{@net.id})")
          @net
        end

        def available_networks
          org.networks.map { |network| "#{network.name} (#{network.id})"}
        end

        def template
          return @template if @template

          # TODO: find by catalog item ID and/or NAME
          # TODO: add option to search just public and/or private catalogs
          Chef::Log.debug("Searching catalogs for image #{config_value(:image)}...")
          org.catalogs.each do |catalog|
            Chef::Log.debug("Searching catalog #{catalog.name}...")

            images = catalog.catalog_items
            @template = images.find { |image| image.name == config_value(:image) }

            if @template.nil?
              Chef::Log.debug("Image not found in catalog #{catalog.name} - possible images: #{images.map(&:name).join(', ')}")
            else
              Chef::Log.debug("Image #{@template.name} (#{template.id}) found in catalog #{catalog.name} - search complete.")
              break
            end
          end

          raise "Unable to locate image #{config_value(:image)} in any catalog" if @template.nil?
          @template
        end

        def vapp
          @vapp ||= vdc.vapps.get_by_name(config_value(:chef_node_name))
        end

        def vm
          @vm ||= vapp.vms.find {|v| v.vapp_name == config_value(:chef_node_name)}
        end

        def network_config
          @network_config ||= vapp.network_config.find do |n|
            n if n[:networkName].match(net.name)
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
