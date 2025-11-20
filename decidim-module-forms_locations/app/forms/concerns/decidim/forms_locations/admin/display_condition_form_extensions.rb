# frozen_string_literal: true

module Decidim
  module FormsLocations
    module Admin
      module DisplayConditionFormExtensions
        extend ActiveSupport::Concern

        included do
          attribute :decidim_map_option_id, Integer

          validates :map_option, presence: true, if: :map_option_mandatory?

          validate :valid_map_option?, unless: :deleted

          def map_options
            return [] if condition_question.blank?

            condition_question.map_options
          end

          def map_option
            @map_option ||= MapOption.find_by(id: decidim_map_option_id)
          end

          private

          def map_option_mandatory?
            !deleted && %w(equal not_equal).include?(condition_type)
          end

          def valid_map_option?
            return unless map_option_mandatory?
            return if map_option.blank?

            errors.add(:decidim_map_option_id, :invalid) if map_option.question.id != decidim_condition_question_id
          end
        end
      end
    end
  end
end
