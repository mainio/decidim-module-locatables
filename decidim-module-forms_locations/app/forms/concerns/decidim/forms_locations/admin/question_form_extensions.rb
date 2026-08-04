# frozen_string_literal: true

module Decidim
  module FormsLocations
    module Admin
      module QuestionFormExtensions
        extend ActiveSupport::Concern

        included do
          attribute :map_configuration, String, default: "multiple"
          attribute :default_latitude, Float, default: 0
          attribute :default_longitude, Float, default: 0
          attribute :default_zoom, Integer, default: 0
          attribute :geojson, JSON
          attribute :allow_comments, Decidim::Form::Boolean, default: true
          attribute :map_options, [Decidim::Forms::Admin::MapOptionForm]

          validate :response_option_location, if: :select_locations?

          validates :map_options, presence: true, if: :tag_locations?

          def map_locations?
            question_type == "map_locations"
          end

          def select_locations?
            question_type == "select_locations"
          end

          def tag_locations?
            question_type == "tag_locations"
          end

          def response_option_location
            response_options.each do |response_option|
              errors.add(:response_options, :missing) if response_option.geojson.blank?
            end
          end
        end
      end
    end
  end
end
