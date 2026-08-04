# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Shakapacker.register_path("#{base_path}/app/packs", prepend: true)
Decidim::Shakapacker.register_entrypoints(
  decidim_forms_locations: "#{base_path}/app/packs/entrypoints/decidim_forms_locations.js",
  decidim_forms_admin: "#{base_path}/app/packs/entrypoints/decidim_forms_admin.js"
)
