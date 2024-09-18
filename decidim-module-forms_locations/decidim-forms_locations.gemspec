# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/forms_locations/version"

Gem::Specification.new do |s|
  s.version = Decidim::FormsLocations.version
  s.authors = ["Joonas"]
  s.email = ["joonas.aapro@mainiotech.fi"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-forms_locations"
  s.required_ruby_version = ">= 3.0"

  s.name = "decidim-forms_locations"
  s.summary = "A decidim forms_locations module"
  s.description = "Enables location adding with markers for forms."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::FormsLocations.decidim_version
  s.add_dependency "decidim-forms", Decidim::FormsLocations.decidim_version
  s.add_dependency "decidim-locations", Decidim::FormsLocations.decidim_version
  s.metadata["rubygems_mfa_required"] = "true"
end
