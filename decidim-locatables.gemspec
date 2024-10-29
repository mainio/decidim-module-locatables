# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/locatables/version"

Gem::Specification.new do |s|
  s.version = Decidim::Locatables.version
  s.authors = ["Joonas"]
  s.email = ["joonas.aapro@mainiotech.fi"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-locatables"
  s.required_ruby_version = ">= 3.0"

  s.name = "decidim-locatables"
  s.summary = "Locatables module collection for Decidim"
  s.description = "Locatables module collection for Decidim"

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-accountability_locations", Decidim::Locatables.version
  s.add_dependency "decidim-core", Decidim::Locatables.decidim_version
  s.add_dependency "decidim-forms_locations", Decidim::Locatables.version
  s.add_dependency "decidim-meetings_locations", Decidim::Locatables.version
  s.add_dependency "decidim-proposals_locations", Decidim::Locatables.version
  s.metadata["rubygems_mfa_required"] = "true"
end
