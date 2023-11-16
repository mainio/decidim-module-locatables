# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module FormsLocations
    # This is the engine that runs on the public interface of forms_locations.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::FormsLocations

      routes do
        # Add engine routes here
        # resources :forms_locations
        # root to: "forms_locations#index"
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

      initializer "FormsLocations.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_forms_locations.add_customizations", after: "decidim.action_controller" do
        config.to_prepare do
          # Model
          # NOTE: Keep these before the form extensions! Otherwise the question
          #       type validator on the Admin::QuestionForm is incorrectly
          #       defined.
          Decidim::Forms::Answer.include(Decidim::Locations::Locatable)
          Decidim::Forms::Question.include(Decidim::FormsLocations::QuestionExtensions)

          # Form
          Decidim::Forms::QuestionnaireForm.include(Decidim::Locations::LocatableForm)
          Decidim::Forms::AnswerForm.include(Decidim::Locations::LocatableForm)
          Decidim::Forms::AnswerForm.include(Decidim::FormsLocations::AnswerFormExtensions)
          Decidim::Forms::Admin::QuestionForm.include(Decidim::FormsLocations::Admin::QuestionFormExtensions)

          # Commands
          Decidim::Forms::AnswerQuestionnaire.include(Decidim::FormsLocations::AnswerQuestionnaireExtensions)
          Decidim::Forms::Admin::UpdateQuestionnaire.include(Decidim::FormsLocations::Admin::UpdateQuestionnaireExtensions)

          # Presenters
          Decidim::Forms::Admin::QuestionnaireParticipantPresenter.include(Decidim::FormsLocations::Admin::QuestionnaireParticipantPresenterExtensions)
        end
      end
    end
  end
end
