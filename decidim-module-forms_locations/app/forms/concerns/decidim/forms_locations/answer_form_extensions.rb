# frozen_string_literal: true

module Decidim
  module FormsLocations
    module AnswerFormExtensions
      extend ActiveSupport::Concern

      included do
        _validators.reject! { |key, _| key == :body }
        _validate_callbacks.each do |callback|
          _validate_callbacks.delete(callback) if callback.raw_filter.respond_to?(:attributes) && callback.raw_filter.attributes == [:body]
        end

        attribute :latitude, Float
        attribute :longitude, Float

        validates :body, presence: true, if: :mandatory_body?
        validates :latitude, presence: true, if: :mandatory_location?
        validates :longitude, presence: true, if: :mandatory_location?

        validate :select_location_choices, if: -> { question.mandatory && question.select_locations? }

        delegate :mandatory_body?, :mandatory_choices?, :mandatory_location?, :matrix?, to: :question

        private

        def mandatory_body?
          return false if question.map_locations? || question.select_locations? || question.tag_locations?

          question.mandatory_body? if display_conditions_fulfilled?
        end

        def mandatory_location?
          question.mandatory_location? if display_conditions_fulfilled?
        end

        def select_location_choices
          errors.add(:choices, :missing) if selected_choices.count <= 0
        end

        def mandatory_tags?; end
      end
    end
  end
end
