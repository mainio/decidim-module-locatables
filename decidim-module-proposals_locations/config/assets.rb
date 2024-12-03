# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs", prepend: true)

Decidim::Webpacker.register_entrypoints(
  decidim_proposals_locations: "#{base_path}/app/packs/entrypoints/decidim_proposals_locations.js"
)
