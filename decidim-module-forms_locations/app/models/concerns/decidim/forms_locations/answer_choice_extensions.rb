# frozen_string_literal: true

module Decidim
  module FormsLocations
    module AnswerChoiceExtensions
      extend ActiveSupport::Concern

      included do
        # Define a module variable to track if the association has been defined
        class_attribute :answer_option_association_defined
        self.answer_option_association_defined = false unless self.answer_option_association_defined

        # Redefine the belongs_to :answer_option association if not already defined
        unless self.answer_option_association_defined
          belongs_to :answer_option,
                    class_name: "AnswerOption",
                    foreign_key: "decidim_answer_option_id",
                    optional: true

          self.answer_option_association_defined = true
        end

        belongs_to :location_option,
                  class_name: "LocationOption",
                  foreign_key: "decidim_location_option_id",
                  optional: true
      end
    end
  end
end
