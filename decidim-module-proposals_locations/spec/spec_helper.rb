# frozen_string_literal: true

require "decidim/dev"

ENV["ENGINE_ROOT"] = File.dirname(__dir__)

Decidim::Dev.dummy_app_path = if ENV["GITHUB_ACTIONS"]
                                File.expand_path(File.join("..", "spec", "decidim_dummy_app"))
                              else
                                File.expand_path(File.join("spec", "decidim_dummy_app"))
                              end

require "decidim/dev/test/base_spec_helper"

RSpec.configure do |config|
  config.before :each, type: :system do
    allow(Decidim).to receive(:maps).and_return(
      provider: :test,
      dynamic: {
        tile_layer: { url: "/tiles/{z}/{x}/{y}.png" }
      },
      geocoding: { url: "/geocode" },
      autocomplete: { url: "/geocode", address_format: [%w(street housenumber), "city", "country"] }
    )
  end
end

require "#{Dir.pwd}/lib/decidim/proposals_locations/test/rspec_support/capybara.rb"
