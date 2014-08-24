#
# Author:: Matt Ray (<matt@getchef.com>)
# Copyright:: Copyright (c) 2014 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/knife/vcair_vm_delete'
require 'chef/knife/cloud/vcair_service_options'

class Chef
  class Knife
    class Cloud
      class VcairServerDelete < VcairVmDelete
        include VcairServiceOptions
        include ServerDeleteOptions

        banner "knife vcair server delete INSTANCEID [INSTANCEID] (options)"

      end
    end
  end
end
