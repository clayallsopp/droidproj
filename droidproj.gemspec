# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "droidproj"

Gem::Specification.new do |s|
  s.name        = "droidproj"
  s.license     = "MIT"
  s.authors     = ["Clay Allsopp"]
  s.email       = "clay@usepropeller.com"
  s.homepage    = "http://usepropeler.com"
  s.version     = DroidProj::VERSION
  s.platform    = Gem::Platform::RUBY
  s.summary     = "DroidProj"
  s.description = "Manage Android projects with a Droidfile"

  s.add_dependency "colorize", "~> 0.5.8"

  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"

  s.files         = Dir["./**/*"].reject { |file| file =~ /\.\/(bin|log|pkg|script|spec|test|vendor)/ }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end