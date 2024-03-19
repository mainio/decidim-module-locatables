# frozen_string_literal: true

module Decidim
  module FormsLocations
    module AnswerChoiceFormExtensions
      extend ActiveSupport::Concern

      included do
        _validators.reject! { |key, _| key == :answer_option_id }

        _validate_callbacks.each do |callback|
          if callback.raw_filter.is_a?(ActiveModel::Validations::PresenceValidator) &&
             callback.raw_filter.attributes == [:answer_option_id]
            _validate_callbacks.delete(callback)
          end
        end

        attribute :geojson, JSON
        attribute :location_option_id, Integer

        validates :location_option_id, presence: true, if: :location_option?
        validates :answer_option_id, presence: true, if: :answer_option?

        def location_option?
          geojson.present?
        end

        def answer_option?
          body.present?
        end
      end
    end
  end
end
