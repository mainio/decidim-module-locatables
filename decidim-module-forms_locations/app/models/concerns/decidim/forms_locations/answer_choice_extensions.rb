# frozen_string_literal: true

module Decidim
  module FormsLocations
    module AnswerChoiceExtensions
      extend ActiveSupport::Concern

      included do
        belongs_to :location_option,
                   class_name: "LocationOption",
                   foreign_key: "decidim_answer_option_id"
      end
    end
  end
end
