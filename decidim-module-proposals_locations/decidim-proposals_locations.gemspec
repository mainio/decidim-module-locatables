# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/proposals_locations/version"

Gem::Specification.new do |s|
  s.version = Decidim::ProposalsLocations.version
  s.authors = ["Joonas"]
  s.email = ["joonas.aapro@mainiotech.fi"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-proposals_locations"
  s.required_ruby_version = ">= 3.1"

  s.name = "decidim-proposals_locations"
  s.summary = "A decidim locations module"
  s.description = "Enables multiple pinpoints on the map."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::ProposalsLocations.decidim_version
  s.add_dependency "decidim-locations", Decidim::ProposalsLocations.decidim_version
  s.add_dependency "decidim-proposals", Decidim::ProposalsLocations.decidim_version
  s.metadata["rubygems_mfa_required"] = "true"
end
