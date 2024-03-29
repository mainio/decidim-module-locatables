# frozen_string_literal: true

module Decidim
  module FormsLocations
    module Admin
      # This class holds a Form to update answer options
      class LocationOptionForm < Decidim::Form
        attribute :deleted, Boolean, default: false
        attribute :title, String
        attribute :body, JSON

        validates :title, presence: true, unless: :deleted
        validates :body, presence: true, unless: :deleted

        def to_param
          return id if id.present?

          "questionnaire-question-location-option-id"
        end
      end
    end
  end
end
