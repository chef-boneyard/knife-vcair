#
# Author:: Vulk <wolfpack@vulk.co>
# Copyright:: Copyright (c) 2014 Chef Inc
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

require File.expand_path('../../../../../spec_helper', __FILE__)
require 'fog'
require 'chef/knife/bootstrap'
require 'chef/knife/bootstrap_windows_winrm'

def vcair
  @vcair ||= Fog::Compute::VcloudDirector.new(
    :connection_options => {
      :ssl_verify_peer => false,
      :connect_timeout => 200,
      :read_timeout => 200
    }
  )
end

## TODO: make sure variables are consistent for VCAir/Vcloud Director.. etc

describe Chef::Knife::Cloud::VcairServerCreate do
  before(:each) do
    @knife_vcair_create = Chef::Knife::Cloud::VcairServerCreate.new
    @knife_vcair_create.stub(:tcp_test_ssh).and_return(true)
    @knife_vcair_create.stub(:tcp_test_winrm).and_return(true)
    {
      :image => 'image',
      :vcair_password => ENV['VCAIR_PASSWORD'] || 'vcair_password',
      :vcair_username => ENV['VCAIR_USERNAME'] || 'vcair_username',
      :vcair_api_host => ENV['VCAIR_HOST'] || 'vcair_host',
      :vcair_org => ENV['VCAIR_ORG'] || 'vcair_org',
      :vcair_catalog_item => ENV['VCLOUD_CATALOG_ITEM'] || 'vcair_catalog_item',
      :vcair_vm_name => ((ENV['VCAIR_VMNAME']).nil? ? ('TESTING-KNIFE' + rand.to_s) : (ENV['VCAIR_VMNAME']) + rand.to_s),
      :vcair_api_version => '5.6',
      :chef_node_name => 'chef_node_name',
    }.each do |key, value|
      @knife_vcair_create.config[key] = value
    end

    @knife_vcair_create.stub(:puts)
    @knife_vcair_create.stub(:print)

    @vcair_connection = double(Fog::Compute::VcloudDirector)
    #@vcair_org = double(Fog::Compute::VcloudDirector::....

# [  <Fog::Compute::VcloudDirector::Organization
#     id="5856ae9f-22c7-4453-952a-12868fdce6e4",
#     name="M511664989-4904",
#     type="application/vnd.vmware.vcloud.org+xml",
#     href="https://p3v11-vcd.vcair.vmware.com:443/api/org/5856ae9f-22c7-4453-952a-12868fdce6e4",
#     description=NonLoaded,
#     full_name=NonLoaded
#   >]

    @catalog_items = [double(:href => "image", :password_enabled? => true)]
    @catalogs = [double(:href => "catalog", :catalog_items => @catalog_items)]
    @vcair_connection.stub_chain(:catalogs).and_return( @catalogs )
    @network = double(:name => "network", :href => "vcair_network")
    @vcair_connection.stub_chain(:networks, :all, :find).and_return( @network )
    @vcair_vapps = double()
    @new_vapp = double(:name => "name", :href => "vapp", :children => {:href => "children"})
    @new_server = double(
      :id => "id",
      :network => {:network_name => "vcair_network", :network_mode => "POOL" },
      :password => 'password',
      :cpus => 'cpus',
      :memory => 'memory'
    )
  end

  describe "run" do
    before do
      #Fog::Compute::VcloudDirector.should_receive(:new).and_return(@vcair_connection)
      #@vcair_connection.should_receive(:servers).and_return( @vcair_vapps )
      #@vcair_vapps.should_receive(:create).and_return( @new_vapp )
      #@new_vapp.should_receive(:wait_for)
      #@new_server.should_receive(:wait_for).twice
      #@new_server.should_receive(:power_on).and_return(true)
      #@new_server.should_receive(:network=).and_return(@new_server.network)
      #@vcair_connection.should_receive(:get_vapp).and_return( @new_vapp )
      #@vcair_connection.should_receive(:get_server).and_return( @new_server )
    end

    it "creates an vapp and bootstraps it" do
      # TODO: mock out the vcair_connetion completely
      #Fog::Compute::VcloudDirector.should_receive(:new).and_return(@vcair_connection)
      #@new_server.should_receive(:save)
      @bootstrap = Chef::Knife::Bootstrap.new
      Chef::Knife::Bootstrap.stub(:new).and_return(@bootstrap)
      #@bootstrap.should_receive(:run)
      @knife_vcair_create.run
    end

  #   it "creates an vapp with non-default CPU/Memory" do
  #     # Fog::Vcloud::Compute.should_receive(:new).and_return(@vcair_connection)
  #     @new_network = {:IpAddress => "IpAddress"}
  #     @new_server.stub(:network).and_return(@new_network)
  #     @knife_vcair_create.config[:vcpus] = 'vcpus'
  #     @knife_vcair_create.config[:memory] = 'memory'
  #     @new_server.should_receive(:cpus=).and_return(@new_server.cpus)
  #     @new_server.should_receive(:memory=).and_return(@new_server.memory)
  #     @new_server.should_receive(:save).exactly(3).times

  #     @bootstrap = Chef::Knife::Bootstrap.new
  #     Chef::Knife::Bootstrap.stub(:new).and_return(@bootstrap)
  #     @bootstrap.should_receive(:run)
  #     @knife_vcair_create.run
  #   end

  #   it "should bootstrap windows when bootstrap protocol is winrm" do
  #     # Fog::Vcloud::Compute.should_receive(:new).and_return(@vcair_connection)
  #     @new_server.should_receive(:save)
  #     @knife_vcair_create.config[:bootstrap_protocol] = 'winrm'
  #     @bootstrap = Chef::Knife::BootstrapWindowsWinrm.new
  #     Chef::Knife::BootstrapWindowsWinrm.stub(:new).and_return(@bootstrap)
  #     @bootstrap.should_receive(:run)
  #     @knife_vcair_create.run
  #   end

  #   it "should set the password on server if the image is not password enabled" do
  #     Fog::Vcloud::Compute.stub(:new).and_return(@vcair_connection)
  #     @catalog_items[0] =double(:href => "image", :password_enabled? => false)
  #     @new_network = {:IpAddress => "IpAddress"}
  #     @new_server.stub(:network).and_return(@new_network)
  #     @new_server.should_receive(:password=)
  #     @new_server.should_receive(:save).twice
  #     @bootstrap = Chef::Knife::Bootstrap.new
  #     Chef::Knife::Bootstrap.stub!(:new).and_return(@bootstrap)
  #     @bootstrap.should_receive(:run)
  #     @knife_vcair_create.run
  #   end

  #   it "should not bootstrap when no_bootstrap set" do
  #     Fog::Vcloud::Compute.stub(:new).and_return(@vcair_connection)
  #     @new_server.should_receive(:save)
  #     @knife_vcair_create.config[:no_bootstrap] = true
  #     @bootstrap = Chef::Knife::Bootstrap.new
  #     @bootstrap.should_not_receive(:run)
  #     lambda  { @knife_vcair_create.run }.should raise_error SystemExit
  #   end

  # end
  # describe "run" do
  #   before do
  #     @knife_vcair_create.ui.stub(:error)
  #   end
  #   it 'should fail if compulsory params - image are not set' do
  #     @knife_vcair_create.config[:image] = nil
  #     lambda  { @knife_vcair_create.run }.should raise_error SystemExit
  #   end
  #   it 'should fail if compulsory params - network are not set' do
  #     @knife_vcair_create.config[:vcair_network] = nil
  #     lambda  { @knife_vcair_create.run }.should raise_error SystemExit
  #   end

  # end
  # describe "when configuring the bootstrap process" do
  #   before do
  #     @knife_vcair_create.config[:ssh_user] = "ubuntu"
  #     @knife_vcair_create.config[:chef_node_name] = "blarf"
  #     @knife_vcair_create.config[:template_file] = '~/.chef/templates/my-bootstrap.sh.erb'
  #     @knife_vcair_create.config[:distro] = 'ubuntu-10.04-magic-sparkles'
  #     @knife_vcair_create.config[:run_list] = ['role[base]']
  #     @knife_vcair_create.config[:json_attributes] = "{'my_attributes':{'foo':'bar'}"
  #     @knife_vcair_create.config[:bootstrap_protocol] = nil

  #     @new_server.stub(:name).and_return("server_name")
  #     @fqdn = mock()
  #     @bootstrap = @knife_vcair_create.bootstrap_for_node(@new_server, @fqdn)
  #   end

  #   it "configures sets the bootstrap's run_list" do
  #     @bootstrap.config[:run_list].should == ['role[base]']
  #   end

  #   it "configures the bootstrap to use the correct ssh_user login" do
  #     @bootstrap.config[:ssh_user].should == 'ubuntu'
  #   end

  #   it "configures the bootstrap to use the configured node name if provided" do
  #     @bootstrap.config[:chef_node_name].should == 'blarf'
  #   end

  #   it "configures the bootstrap to use the vcair server name if no explicit node name is set" do
  #     @knife_vcair_create.config[:chef_node_name] = nil

  #     bootstrap = @knife_vcair_create.bootstrap_for_node(@new_server, @fqdn)
  #     bootstrap.config[:chef_node_name].should == @new_server.name
  #   end

  #   it "configures the bootstrap to use prerelease versions of chef if specified" do
  #     @bootstrap.config[:prerelease].should be_false

  #     @knife_vcair_create.config[:prerelease] = true

  #     bootstrap = @knife_vcair_create.bootstrap_for_node(@new_server, @fqdn)
  #     bootstrap.config[:prerelease].should be_true
  #   end

  #   it "configures the bootstrap to use the desired distro-specific bootstrap script" do
  #     @bootstrap.config[:distro].should == 'ubuntu-10.04-magic-sparkles'
  #   end

  #   it "configures the bootstrap to use sudo" do
  #     @bootstrap.config[:use_sudo].should be_true
  #   end

  #   it "configured the bootstrap to use the desired template" do
  #     @bootstrap.config[:template_file].should == '~/.chef/templates/my-bootstrap.sh.erb'
  #   end

  #   it "configured the bootstrap to set an vcair hint (via Chef::Config)" do
  #     Chef::Config[:knife][:hints]["vcair"].should_not be_nil
  #   end
  end
end
