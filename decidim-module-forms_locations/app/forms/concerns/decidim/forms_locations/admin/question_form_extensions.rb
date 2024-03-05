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
          attribute :location_options, Array[LocationOptionForm]

          validates :location_options, presence: true, if: :select_locations?

          def number_of_options
            if select_locations?
              location_options.size
            else
              answer_options.size
            end
          end

          def map_locations?
            question_type == "map_locations"
          end

          def select_locations?
            question_type == "select_locations"
          end
        end
      end
    end
  end
end
