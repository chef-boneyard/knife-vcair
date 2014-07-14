#
# Author:: Seth Thomas
# Copyright:: 
#

require 'chef/knife/cloud/list_resource_command'
require 'chef/knife/vchs_helpers'
require 'chef/knife/cloud/vchs_service_options'

# TODO - Your cloud may or may not support this. If no, simply delete this file.

class Chef
  class Knife
    class Cloud
      class VchsVmList < ResourceListCommand
        include VchsHelpers
        include VchsServiceOptions

        banner "knife vchs vm list (options)"

        def query_resource
          begin
          @service.connection.organizations

          rescue Excon::Errors::BadRequest => e
            response = Chef::JSONCompat.from_json(e.response.body)
            ui.fatal("Unknown server error (#{response['badRequest']['code']}): #{response['badRequest']['message']}")
            raise e
          end
        end

           
      	def list(organizations)
          vm_list = [
            ui.color('Name', :bold),
            ui.color('OS', :bold),
            ui.color('IP', :bold),
            ui.color('vAPP', :bold),
            ui.color('CPU', :bold),
            ui.color('Status', :bold),
          ]
          org = organizations.get_by_name(Chef::Config[:knife][:vchs_org])
          vdcs = org.vdcs.all
          if vdcs
            for vdc in vdcs
              vdc.vapps.all.each do |vapp|
                vapp.vms.sort_by(&:name).each do |vm|
                  vm_list << vm.name
                  vm_list << vm.operating_system
                  vm_list << vm.ip_address
                  vm_list << vm.vapp_name
                  vm_list << vm.cpu.to_s
                  vm_list << vm.status
                end
              end
            end
          end
        puts ui.list(vm_list, :uneven_columns_across, 6)
        end
      end
    end
  end
end
