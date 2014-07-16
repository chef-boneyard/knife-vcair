$:.unshift File.expand_path('../../lib', __FILE__)
require 'chef/knife/bootstrap'
require 'chef/knife/vchs_helpers'
require 'fog'
require 'chef/knife/winrm_base'
require 'chef/knife/bootstrap_windows_winrm'
require 'chef/knife/vchs_server_create'
require 'chef/knife/vchs_server_delete'
require 'chef/knife/bootstrap_windows_ssh'
require "securerandom"
require 'knife-vchs/version'
require 'test/knife-utils/test_bed'
require 'resource_spec_helper'

