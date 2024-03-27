# frozen_string_literal: true

module Decidim
  module FormsLocations
    module AnswerFormExtensions
      extend ActiveSupport::Concern

      included do
        attribute :latitude, Float
        attribute :longitude, Float

        validates :latitude, presence: true, if: :mandatory_location?
        validates :longitude, presence: true, if: :mandatory_location?

        validate :select_location_choices, if: -> { question.mandatory && question.select_locations? }

        delegate :mandatory_body?, :mandatory_choices?, :mandatory_location?, :matrix?, to: :question

        private

        def mandatory_location?
          question.mandatory_location? if display_conditions_fulfilled?
        end

        def select_location_choices
          errors.add(:choices, :missing) if selected_choices.count <= 0
        end
      end
    end
  end
end
