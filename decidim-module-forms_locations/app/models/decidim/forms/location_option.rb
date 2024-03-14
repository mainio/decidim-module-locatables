# frozen_string_literal: true

module Decidim
  module Forms
    class LocationOption < Forms::ApplicationRecord
      belongs_to :question, class_name: "Question", foreign_key: "decidim_question_id"

      has_many :display_conditions,
               class_name: "DisplayCondition",
               foreign_key: "decidim_location_option_id",
               dependent: :nullify,
               inverse_of: :location_option
    end
  end
end
