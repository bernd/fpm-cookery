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

  s.add_development_dependency "minitest", "~> 4.0"
  s.add_development_dependency "rake"
  s.add_runtime_dependency "fpm", "~> 0.4"
  s.add_runtime_dependency "facter"
  s.add_runtime_dependency "puppet"
  s.add_runtime_dependency "addressable"
end
