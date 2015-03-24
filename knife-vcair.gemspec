# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "knife-vcair/version"

Gem::Specification.new do |s|
  s.name        = "knife-vcair"
  s.version     = Knife::Vcair::VERSION
  s.platform    = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.md", "LICENSE" ]
  s.authors     = ["Matt Ray", "Chris McClimans", "Taylor Carpenter", "Wavell Watson", "Seth Thomas"]
  s.email       = ["matt@chef.io", "wolfpack@vulk.co", "sthomas@chef.io"]
  s.homepage    = "https://github.com/chef-partners/knife-vcair"
  s.summary     = %q{VMware vcair support for Chef's Knife command}
  s.description = s.summary

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "fog", ">= 1.23"
  s.add_dependency "knife-cloud", ">= 1.0.1"
  s.add_dependency "knife-windows", ">= 0.8.3"

  s.add_development_dependency 'chef', '>= 11.16.2', '< 12'
  s.add_development_dependency 'rspec',         '~> 2.14'
  s.add_development_dependency 'rake',          '~> 10.1'
  s.add_development_dependency 'guard-rspec', ["~> 4.2"]
  s.add_development_dependency 'activesupport'

  %w(rspec-core rspec-expectations rspec-mocks rspec_junit_formatter).each { |gem|
    s.add_development_dependency gem
  }
end
