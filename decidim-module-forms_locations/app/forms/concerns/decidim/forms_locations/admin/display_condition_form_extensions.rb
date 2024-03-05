# frozen_string_literal: true

module Decidim
  module FormsLocations
    module Admin
      module DisplayConditionFormExtensions
        extend ActiveSupport::Concern

        included do
          attribute :decidim_location_option_id, Integer

          validates :location_option, presence: true, if: :location_option_mandatory?

          validate :valid_location_option?, unless: :deleted

          def location_options
            return [] if condition_question.blank?

            condition_question.location_options
          end

          def location_option
            @location_option ||= LocationOption.find_by(id: decidim_location_option_id)
          end

          def location_option_mandatory?
            !deleted && %w(equal not_equal).include?(condition_type)
          end

          def valid_locaton_option?
            return unless location_option_mandatory?
            return if location_option.blank?

            errors.add(:decidim_location_option_id, :invalid) if location_option.question.id != decidim_condition_question_id
          end
        end
      end
    end
  end
end
