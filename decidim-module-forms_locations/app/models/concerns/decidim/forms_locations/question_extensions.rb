# frozen_string_literal: true

module Decidim
  module FormsLocations
    module QuestionExtensions
      extend ActiveSupport::Concern

      included do |base|
        base.class_eval do
          question_types = remove_const(:QUESTION_TYPES)
          question_types += %w(map_locations) unless question_types.include?("map_locations")
          question_types += %w(select_locations) unless question_types.include?("select_locations")
          const_set(:QUESTION_TYPES, question_types.freeze)

          remove_const(:TYPES)
          const_set(:TYPES, (question_types + [const_get(:SEPARATOR_TYPE), const_get(:TITLE_AND_DESCRIPTION_TYPE)]).freeze)
        end

        # Redefine the question_type inclusion validator
        _validators.reject! { |key, _| key == :question_type }
        _validate_callbacks.each do |callback|
          _validate_callbacks.delete(callback) if callback.raw_filter.respond_to?(:attributes) && callback.raw_filter.attributes == [:question_type]
        end

        has_many :location_options,
                 class_name: "LocationOption",
                 foreign_key: "decidim_question_id",
                 dependent: :destroy,
                 inverse_of: :question

        validates :question_type, inclusion: { in: const_get(:TYPES) }

        scope :with_choices, -> { where.not(question_type: %w(short_answer long_answer map_locations)) }

        def number_of_options
          if question_type == "select_locations"
            location_options.size
          else
            answer_options.size
          end
        end

        def mandatory_body?
          mandatory? && !multiple_choice? && !has_attachments? && !map_locations? && !select_locations?
        end

        def mandatory_location?
          mandatory? && (map_locations? || select_locations?)
        end

        def map_locations?
          question_type == "map_locations"
        end

        def select_locations?
          question_type == "select_locations"
        end
      end
    end
  end
end
