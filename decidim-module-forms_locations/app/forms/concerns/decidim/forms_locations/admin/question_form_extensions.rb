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

          validate :answer_option_location, if: :select_locations?

          def map_locations?
            question_type == "map_locations"
          end

          def select_locations?
            question_type == "select_locations"
          end

          def answer_option_location
            answer_options.each do |answer_option|
              if answer_option.geojson.blank?
                errors.add(:answer_options, :missing)
              end
            end
          end
        end
      end
    end
  end
end
