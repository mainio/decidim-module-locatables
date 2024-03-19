# frozen_string_literal: true

module Decidim
  module FormsLocations
    module Admin
      # This class holds a Form to update answer options
      class LocationOptionForm < Decidim::Form
        attribute :deleted, Boolean, default: false
        attribute :location, String
        attribute :geojson, JSON

        validates :location, presence: true, unless: :deleted
        validates :geojson, presence: true, unless: :deleted

        def to_param
          return id if id.present?

          "questionnaire-question-location-option-id"
        end
      end
    end
  end
end
