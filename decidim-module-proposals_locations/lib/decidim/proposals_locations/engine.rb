# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module ProposalsLocations
    # This is the engine that runs on the public interface of locations.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::ProposalsLocations

      initializer "proposals_locations.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_proposals_locations.add_global_component_settings_and_export", after: "decidim_locations.settings_manifest_customization" do
        config.to_prepare do
          manifest = Decidim.find_component_manifest("proposals")
          manifest.settings(:global) do |settings|
            settings.attribute :default_latitude, type: :float, default: 0
            settings.attribute :default_longitude, type: :float, default: 0
          end

          manifest.exports :locations do |exports|
            exports.collection do |component_instance|
              Decidim::Proposals::Proposal
                .where(component: component_instance.id)
                .flat_map(&:locations)
            end

            exports.include_in_open_data = true

            exports.serializer Decidim::Locations::LocationSerializer
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

      initializer "decidim_proposal_locations.add_customizations", after: "decidim.action_controller" do
        config.to_prepare do
          # Command
          Decidim::Proposals::UpdateProposal.include(Decidim::ProposalsLocations::UpdateProposalExtensions)
          Decidim::Proposals::Admin::UpdateProposal.include(Decidim::ProposalsLocations::Admin::UpdateProposalExtensions)
          Decidim::Proposals::Admin::CreateProposal.include(Decidim::ProposalsLocations::Admin::CreateProposalExtensions)

          # Form
          Decidim::Proposals::ProposalForm.include(Decidim::Locations::LocatableForm)
          Decidim::Proposals::Admin::ProposalForm.include(Decidim::Locations::LocatableForm)

          # Type
          Decidim::Proposals::ProposalType.implements(Decidim::Locations::LocationsInterface)

          # Model
          Decidim::Proposals::Proposal.include(Decidim::Locations::Locatable)
        end
      end
    end
  end
end
