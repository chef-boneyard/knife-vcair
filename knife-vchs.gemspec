# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "knife-vchs/version"

Gem::Specification.new do |s|
  s.name        = "knife-vchs"
  s.version     = Knife::Vchs::VERSION
  s.platform    = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.md", "LICENSE" ]
  s.authors     = ["Matt Ray"]
  s.email       = ["matt@getchef.com"]
  s.homepage    = "https://github.com/chef-partners/knife-vchs"
  s.summary     = %q{VMware vCHS support for Chef's Knife command}
  s.description = s.summary

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "knife-cloud"

  %w(rspec-core rspec-expectations rspec-mocks rspec_junit_formatter).each { |gem| s.add_development_dependency gem }
end
