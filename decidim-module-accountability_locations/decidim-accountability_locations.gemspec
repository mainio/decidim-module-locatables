# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/accountability_locations/version"

Gem::Specification.new do |s|
  s.version = Decidim::AccountabilityLocations.version
  s.authors = ["Joonas"]
  s.email = ["joonas.aapro@mainiotech.fi"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-accountability_locations"
  s.required_ruby_version = ">= 3.0"

  s.name = "decidim-accountability_locations"
  s.summary = "A decidim accountability_locations module"
  s.description = "Enables location adding with markers for the accountability component.."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::AccountabilityLocations.version
  s.metadata["rubygems_mfa_required"] = "true"
end
