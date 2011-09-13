# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "brainz_releases/version"

Gem::Specification.new do |s|
  s.name        = "brainz_releases"
  s.version     = BrainzReleases::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Paul Sturgess"]
  s.email       = ["paulsturgess@gmail.com"]
  s.homepage    = "https://github.com/paulsturgess/brainz_releases"
  s.summary     = "Provides a ruby inteface for extracting the releases for an artist from MusicBrainz"
  s.description = "Uses the MusicBrainz XML Web Service (version 2) to extract the releases for an artist and turn them into nice ruby objects."

  s.rubyforge_project = "brainz_releases"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "nokogiri", "~> 1.4"
  s.add_development_dependency "rspec", "~> 2.6"
  s.add_development_dependency "fakeweb", "~> 1.3.0"
end
