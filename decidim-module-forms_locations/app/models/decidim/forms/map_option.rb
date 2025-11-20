# frozen_string_literal: true

module Decidim
  module Forms
    class MapOption < Forms::ApplicationRecord
      include Decidim::TranslatableResource

      default_scope { order(arel_table[:id].asc) }

      translatable_fields :label, :shape

      belongs_to :question, class_name: "Question", foreign_key: "decidim_question_id"

      has_many :display_conditions,
               class_name: "DisplayCondition",
               foreign_key: "decidim_map_option_id",
               dependent: :nullify,
               inverse_of: :answer_option

      def translated_label
        Decidim::Forms::MapOptionPresenter.new(self).translated_label
      end

      def translated_shape
        Decidim::Forms::MapOptionPresenter.new(self).translated_shape
      end
    end
  end
end
