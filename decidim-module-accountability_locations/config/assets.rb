# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Shakapacker.register_path("#{base_path}/app/packs")
Decidim::Shakapacker.register_entrypoints(
  decidim_accountability_locations: "#{base_path}/app/packs/entrypoints/decidim_accountability_locations.js",
  decidim_accountability_locations_admin: "#{base_path}/app/packs/entrypoints/decidim_accountability_locations_admin.js"
)
