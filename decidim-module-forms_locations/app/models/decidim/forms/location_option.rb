# frozen_string_literal: true

module Decidim
  module Forms
    class LocationOption < Forms::ApplicationRecord
      include Decidim::TranslatableResource

      default_scope { order(arel_table[:id].asc) }

      belongs_to :question, class_name: "Question", foreign_key: "decidim_question_id"

      has_many :display_conditions,
               class_name: "DisplayCondition",
               foreign_key: "decidim_answer_option_id",
               dependent: :nullify,
               inverse_of: :answer_option
    end
  end
end
