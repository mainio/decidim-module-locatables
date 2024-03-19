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

        delegate :mandatory_body?, :mandatory_choices?, :mandatory_location?, :matrix?, to: :question

        def selected_choices
          choices.select { |choice| choice.body || choice.geojson }
        end

        private

        def mandatory_location?
          question.mandatory_location? if display_conditions_fulfilled?
        end
      end
    end
  end
end
