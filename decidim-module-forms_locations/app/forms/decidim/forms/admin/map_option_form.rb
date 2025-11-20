# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      class MapOptionForm < Decidim::Form
        include TranslatableAttributes

        attribute :deleted, Boolean, default: false
        attribute :color, String

        translatable_attribute :label, String
        translatable_attribute :shape, String

        validates :label, translatable_presence: true, unless: :deleted
        validates :shape, translatable_presence: true, unless: :deleted

        def to_param
          return id if id.present?

          "questionnaire-question-map-option-id"
        end
      end
    end
  end
end
