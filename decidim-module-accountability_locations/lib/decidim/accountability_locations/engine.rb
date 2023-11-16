# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module AccountabilityLocations
    # This is the engine that runs on the public interface of accountability_locations.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::AccountabilityLocations

      routes do
        # Add engine routes here
        # resources :accountability_locations
        # root to: "accountability_locations#index"
      end

      initializer "decidim_accountability_locations.add_global_component_settings", after: "decidim_locations.settings_manifest_customization" do
        config.to_prepare do
          manifest = Decidim.find_component_manifest("accountability")
          manifest.settings(:global) do |settings|
            settings.attribute :default_latitude, type: :float, default: 0
            settings.attribute :default_longitude, type: :float, default: 0
          end
        end
      end

      if Rails.env.test?
        # We need a local tiles route for the map tests not to show any HTTP 500
        # errors.
        initializer "proposals_locations.mount_routes", before: :add_routing_paths do
          geocode_response = {
            type: "FeatureCollection",
            features: [
              {
                geometry: {
                  coordinates: [24.886418020451863, 60.152602900000005],
                  type: "Point"
                },
                type: "Feature",
                properties: {
                  osm_type: "W",
                  osm_key: "building",
                  country: "Finland",
                  countrycode: "FI",
                  street: "Veneentekijäntie",
                  housenumber: 4,
                  type: "house"
                }
              },
              {
                geometry: {
                  coordinates: [24.8886319, 60.1523368],
                  type: "Point"
                },
                type: "Feature",
                properties: {
                  osm_type: "W",
                  osm_key: "building",
                  country: "Finland",
                  countrycode: "FI",
                  street: "Veneentekijäntie",
                  housenumber: 6,
                  type: "house"
                }
              },
              {
                geometry: {
                  coordinates: [24.8868987, 60.1521989],
                  type: "Point"
                },
                type: "Feature",
                properties: {
                  osm_type: "W",
                  osm_key: "building",
                  country: "Finland",
                  countrycode: "FI",
                  street: "Veneentekijäntie",
                  housenumber: 7,
                  type: "house"
                }
              }
            ]
          }

          Decidim::Core::Engine.routes.prepend do
            get "/tiles/:z/:x/:y", to: ->(_) { [200, {}, [""]] }
            get "/geocode", to: ->(_) { [200, { "Content-Type" => "application/json" }, [geocode_response.to_json]] }
          end
        end
      end

      initializer "AccountabilityLocations.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_accountability_locations.add_customizations", after: "decidim.action_controller" do
        config.to_prepare do
          # Command
          Decidim::Accountability::Admin::CreateResult.include(Decidim::AccountabilityLocations::Admin::CreateResultExtensions)
          Decidim::Accountability::Admin::UpdateResult.include(Decidim::AccountabilityLocations::Admin::UpdateResultExtensions)

          # Controller
          Decidim::Accountability::ResultsController.include(Decidim::AccountabilityLocations::ResultsControllerExtensions)

          # Form
          Decidim::Accountability::Admin::ResultForm.include(Decidim::AccountabilityLocations::Admin::ResultFormExtensions)
          Decidim::Accountability::Admin::ResultForm.include(Decidim::Locations::LocatableForm)

          # Type
          Decidim::Accountability::AccountabilityType.implements(Decidim::Locations::LocationsInterface)

          # Model
          Decidim::Accountability::Result.include(Decidim::Locations::Locatable)
        end
      end
    end
  end
end
