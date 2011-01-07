# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "devserver/version"

Gem::Specification.new do |s|
  s.name        = "devserver"
  s.version     = Devserver::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jason Adam Young"]
  s.email       = ["jay@outfielding.net"]
  s.summary     = %q{Provides a wrapper around thin, similar to passenger standalone, for local ruby on rails development.}
  s.description = %q{Provides a wrapper around thin, similar to passenger standalone, for local ruby on rails development.}
  s.license = 'Apache-v2'
  s.rubyforge_project = "devserver"
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency('thor', '>= 0.14.6')
end
