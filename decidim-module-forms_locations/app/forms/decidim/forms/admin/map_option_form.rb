# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      class MapOptionForm < Decidim::Form
        include TranslatableAttributes

        attribute :color, String, default: "#000000"
        attribute :deleted, Boolean, default: false

        translatable_attribute :label, String
        attribute :shape, String, default: "circle"

        validates :label, translatable_presence: true, unless: :deleted
        validates :shape, presence: true, unless: :deleted

        def to_param
          return id if id.present?

          "questionnaire-question-map-option-id"
        end
      end
    end
  end
end
