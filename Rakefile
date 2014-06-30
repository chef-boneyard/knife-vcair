# Author:: TODO
# Copyright::

require 'bundler'
Bundler::GemHelper.install_tasks

require 'rubygems'
require 'rubygems/package_task'

task :default => :all
task :all => [:spec, :uninstall, :install]

# Packaging
GEM_NAME = "knife-vchs"
require File.dirname(__FILE__) + '/lib/knife-vchs/version'
spec = eval(File.read("knife-vchs.gemspec"))
Gem::PackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "uninstall #{GEM_NAME}-#{Knife::Vchs::VERSION}.gem from system..."
task :uninstall do
  sh %{gem uninstall #{GEM_NAME} -x -v #{Knife::Vchs::VERSION} }
end

# rspec
begin
  require 'rspec/core/rake_task'
  desc "Run all specs in spec directory"
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = 'spec/unit/**/*_spec.rb'
  end
rescue LoadError
  STDERR.puts "\n*** RSpec not available. (sudo) gem install rspec to run unit tests. ***\n\n"
end