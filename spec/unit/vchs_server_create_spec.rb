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

require File.expand_path('../../spec_helper', __FILE__)
require 'fog'
require 'chef/knife/bootstrap'
require 'chef/knife/bootstrap_windows_winrm'


def vcloud_director
  @vcloud_director ||= Fog::Compute::VcloudDirector.new(
    :connection_options => {
      :ssl_verify_peer => false,
      :connect_timeout => 200,
      :read_timeout => 200
    }
  )
end


describe Chef::Knife::Cloud::VchsServerCreate do
  before(:each) do
    @knife_vchs_create = #Chef::Knife::Cloud::VchsServerCreate.new
    @knife_vchs_create.stub(:tcp_test_ssh).and_return(true)
    @knife_vchs_create.stub(:tcp_test_winrm).and_return(true)
    {
      :image => 'image',
      :vchs_password => 'vchs_password',
      :vchs_username => 'vchs_username',
      :vchs_host => 'vchs_host',
      :vchs_network => 'vchs_network',
      :chef_node_name => 'chef_node_name',
      :ssh_password => 'password'
    }.each do |key, value|
      @knife_vchs_create.config[key] = value
    end
    @knife_vchs_create.stub(:puts)
    @knife_vchs_create.stub(:print)

    @vchs_connection = double(Fog::Compute::VcloudDirector)
    @catalog_items = [double(:href => "image", :password_enabled? => true)]
    @catalogs = [double(:href => "catalog", :catalog_items => @catalog_items)]
    @vchs_connection.stub_chain(:catalogs).and_return( @catalogs )
    @network = double(:name => "network", :href => "vchs_network")
    @vchs_connection.stub_chain(:networks, :all, :find).and_return( @network )
    @vchs_vapps = double()
    @new_vapp = double(:name => "name", :href => "vapp", :children => {:href => "children"})
    @new_server = double(
      :id => "id",
      :network => {:network_name => "vchs_network", :network_mode => "POOL" },
      :password => 'password',
      :cpus => 'cpus',
      :memory => 'memory'
    )
  end

  describe "run" do
    before do
      Fog::Compute::VcloudDirector.should_receive(:new).and_return(@vchs_connection)
      @vchs_connection.should_receive(:servers).and_return( @vchs_vapps )
      @vchs_vapps.should_receive(:create).and_return( @new_vapp )
      @new_vapp.should_receive(:wait_for)
      @new_server.should_receive(:wait_for).twice
      @new_server.should_receive(:power_on).and_return(true)
      @new_server.should_receive(:network=).and_return(@new_server.network)
      @vchs_connection.should_receive(:get_vapp).and_return( @new_vapp )
      @vchs_connection.should_receive(:get_server).and_return( @new_server )
    end

    it "creates an vapp and bootstraps it" do
      # Fog::Vcloud::Compute.should_receive(:new).and_return(@vchs_connection)
      @new_server.should_receive(:save)
      @bootstrap = Chef::Knife::Bootstrap.new
      Chef::Knife::Bootstrap.stub(:new).and_return(@bootstrap)
      @bootstrap.should_receive(:run)
      @knife_vchs_create.run
    end

  #   it "creates an vapp with non-default CPU/Memory" do
  #     # Fog::Vcloud::Compute.should_receive(:new).and_return(@vchs_connection)
  #     @new_network = {:IpAddress => "IpAddress"}
  #     @new_server.stub(:network).and_return(@new_network)
  #     @knife_vchs_create.config[:vcpus] = 'vcpus'
  #     @knife_vchs_create.config[:memory] = 'memory'
  #     @new_server.should_receive(:cpus=).and_return(@new_server.cpus)
  #     @new_server.should_receive(:memory=).and_return(@new_server.memory)
  #     @new_server.should_receive(:save).exactly(3).times

  #     @bootstrap = Chef::Knife::Bootstrap.new
  #     Chef::Knife::Bootstrap.stub(:new).and_return(@bootstrap)
  #     @bootstrap.should_receive(:run)
  #     @knife_vchs_create.run
  #   end

  #   it "should bootstrap windows when bootstrap protocol is winrm" do
  #     # Fog::Vcloud::Compute.should_receive(:new).and_return(@vchs_connection)
  #     @new_server.should_receive(:save)
  #     @knife_vchs_create.config[:bootstrap_protocol] = 'winrm'
  #     @bootstrap = Chef::Knife::BootstrapWindowsWinrm.new
  #     Chef::Knife::BootstrapWindowsWinrm.stub(:new).and_return(@bootstrap)
  #     @bootstrap.should_receive(:run)
  #     @knife_vchs_create.run
  #   end

  #   it "should set the password on server if the image is not password enabled" do
  #     Fog::Vcloud::Compute.stub(:new).and_return(@vchs_connection)
  #     @catalog_items[0] =double(:href => "image", :password_enabled? => false)
  #     @new_network = {:IpAddress => "IpAddress"}
  #     @new_server.stub(:network).and_return(@new_network)
  #     @new_server.should_receive(:password=)
  #     @new_server.should_receive(:save).twice
  #     @bootstrap = Chef::Knife::Bootstrap.new
  #     Chef::Knife::Bootstrap.stub!(:new).and_return(@bootstrap)
  #     @bootstrap.should_receive(:run)
  #     @knife_vchs_create.run
  #   end

  #   it "should not bootstrap when no_bootstrap set" do
  #     Fog::Vcloud::Compute.stub(:new).and_return(@vchs_connection)
  #     @new_server.should_receive(:save)
  #     @knife_vchs_create.config[:no_bootstrap] = true
  #     @bootstrap = Chef::Knife::Bootstrap.new
  #     @bootstrap.should_not_receive(:run)
  #     lambda  { @knife_vchs_create.run }.should raise_error SystemExit
  #   end

  # end
  # describe "run" do
  #   before do
  #     @knife_vchs_create.ui.stub(:error)
  #   end
  #   it 'should fail if compulsory params - image are not set' do
  #     @knife_vchs_create.config[:image] = nil
  #     lambda  { @knife_vchs_create.run }.should raise_error SystemExit
  #   end
  #   it 'should fail if compulsory params - network are not set' do
  #     @knife_vchs_create.config[:vchs_network] = nil
  #     lambda  { @knife_vchs_create.run }.should raise_error SystemExit
  #   end

  # end
  # describe "when configuring the bootstrap process" do
  #   before do
  #     @knife_vchs_create.config[:ssh_user] = "ubuntu"
  #     @knife_vchs_create.config[:chef_node_name] = "blarf"
  #     @knife_vchs_create.config[:template_file] = '~/.chef/templates/my-bootstrap.sh.erb'
  #     @knife_vchs_create.config[:distro] = 'ubuntu-10.04-magic-sparkles'
  #     @knife_vchs_create.config[:run_list] = ['role[base]']
  #     @knife_vchs_create.config[:json_attributes] = "{'my_attributes':{'foo':'bar'}"
  #     @knife_vchs_create.config[:bootstrap_protocol] = nil

  #     @new_server.stub(:name).and_return("server_name")
  #     @fqdn = mock()
  #     @bootstrap = @knife_vchs_create.bootstrap_for_node(@new_server, @fqdn)
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

  #   it "configures the bootstrap to use the vchs server name if no explicit node name is set" do
  #     @knife_vchs_create.config[:chef_node_name] = nil

  #     bootstrap = @knife_vchs_create.bootstrap_for_node(@new_server, @fqdn)
  #     bootstrap.config[:chef_node_name].should == @new_server.name
  #   end

  #   it "configures the bootstrap to use prerelease versions of chef if specified" do
  #     @bootstrap.config[:prerelease].should be_false

  #     @knife_vchs_create.config[:prerelease] = true

  #     bootstrap = @knife_vchs_create.bootstrap_for_node(@new_server, @fqdn)
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

  #   it "configured the bootstrap to set an vchs hint (via Chef::Config)" do
  #     Chef::Config[:knife][:hints]["vchs"].should_not be_nil
  #   end
  end
end
