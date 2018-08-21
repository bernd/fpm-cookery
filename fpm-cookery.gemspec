# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fpm/cookery/version"

Gem::Specification.new do |s|
  s.name        = "fpm-cookery"
  s.version     = FPM::Cookery::VERSION
  s.authors     = ["Bernd Ahlers"]
  s.email       = ["bernd@tuneafish.de"]
  s.homepage    = ""
  s.summary     = %q{A tool for building software packages with fpm.}
  s.description = %q{A tool for building software packages with fpm.}

  s.rubyforge_project = "fpm-cookery"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec", "~> 3.3"
  s.add_development_dependency "rake"
  s.add_development_dependency "pry"
  s.add_development_dependency "simplecov", "~> 0.11"
  s.add_runtime_dependency "fpm", "~> 1.1"
  s.add_runtime_dependency "facter"
  s.add_runtime_dependency "puppet", ">= 3.4", "< 6.0"
  s.add_runtime_dependency "addressable", "~> 2.3.8"
  s.add_runtime_dependency "systemu"
  s.add_runtime_dependency "json", ">= 1.7.7", "< 2.0"
  s.add_runtime_dependency "json_pure", ">= 1.7.7", "< 2.0"
  s.add_runtime_dependency "safe_yaml", "~> 1.0.4"
end
