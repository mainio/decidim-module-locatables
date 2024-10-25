# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/meetings_locations/version"

Gem::Specification.new do |s|
  s.version = Decidim::MeetingsLocations.version
  s.authors = ["Joonas"]
  s.email = ["joonas.aapro@mainiotech.fi"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-meetings_locations"
  s.required_ruby_version = ">= 3.1"

  s.name = "decidim-meetings_locations"
  s.summary = "A decidim meetings_locations module"
  s.description = "Enables location adding with markers for the meetings component."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::MeetingsLocations.decidim_version
  s.add_dependency "decidim-locations", Decidim::MeetingsLocations.decidim_version
  s.add_dependency "decidim-meetings", Decidim::MeetingsLocations.decidim_version
  s.metadata["rubygems_mfa_required"] = "true"
end
