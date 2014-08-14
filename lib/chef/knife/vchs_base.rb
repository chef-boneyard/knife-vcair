require 'fog'
class Chef
  class Knife
    module VchsBase
      def self.included(includer)
        includer.class_eval do

          deps do
            require 'chef/knife'
            require 'chef/json_compat'
            Chef::Knife.load_deps
          end

          option :vchs_password,
            :short => "-K PASSWORD",
            :long => "--vchs-password PASSWORD",
            :description => "Your VCHS password",
            :proc => Proc.new { |key| Chef::Config[:knife][:vchs_password] = key }

          option :vchs_username,
            :short => "-A USERNAME",
            :long => "--vchs-username USERNAME",
            :description => "Your VCHS username",
            :proc => Proc.new { |username| Chef::Config[:knife][:vchs_username] = username }

          option :vchs_host,
           :short => "-U HOST",
           :long => "--vchs-host HOST",
           :description => "The VCHS API endpoint",
           :proc => Proc.new { |u| Chef::Config[:knife][:vchs_host] = u }

          option :vchs_org,
           :short => "-U ORG",
           :long => "--vchs-org ORG",
           :description => "The VCHS ORG",
           :proc => Proc.new { |u| Chef::Config[:knife][:vchs_org] = u }

          option :vchs_api_version,
           :short => "-V VERSION",
           :long => "--vchs-host VERSION",
           :description => "The VCHS API version",
           :default => '5.6',
           :proc => Proc.new { |u| Chef::Config[:knife][:vchs_api_version] = u }
        end
      end

      def connection
        Chef::Log.debug("vchs_username #{locate_config_value(:vchs_username)}")
        Chef::Log.debug("vchs_password #{locate_config_value(:vchs_password)}")
        Chef::Log.debug("vchs_host #{locate_config_value(:vchs_host)}")
        Chef::Log.debug("vchs_org #{locate_config_value(:vchs_org)}")
        Chef::Log.debug("vchs_api_version #{locate_config_value(:vchs_api_version)}")

        @connection ||= begin
          connection = Fog::Vchs::Compute.new(
            :vchs_username => locate_config_value(:vchs_username),
            :vchs_password => locate_config_value(:vchs_password),
            :vchs_host => locate_config_value(:vchs_host),
            :vchs_org => locate_config_value(:vchs_org),
            :vchs_api_version => locate_config_value(:vchs_api_version),
            :vchs_catalog_item => locate_config_value(:vchs_catalog_item)
          )
        end
      end

      def locate_config_value(key)
        key = key.to_sym
        Chef::Config[:knife][key] || config[key]
      end

      def msg_pair(label, value, color=:cyan)
        if value && !value.to_s.empty?
          puts "#{ui.color(label, color)}: #{value}"
        end
      end

      def validate!(keys=[:vchs_username, :vchs_password, :vchs_host, :vchs_org, :vchs_api_version])
        errors = []
        keys.each do |k|
          pretty_key = k.to_s.gsub(/_/, ' ').gsub(/\w+/){ |w| (w =~ /(ssh)/i) ? w.upcase  : w.capitalize }
          if locate_config_value(k).nil?
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

