# frozen_string_literal: true

module Decidim
  module Forms
    class MapOption < Forms::ApplicationRecord
      include Decidim::TranslatableResource

      default_scope { order(arel_table[:id].asc) }

      translatable_fields :label

      belongs_to :question, class_name: "Question", foreign_key: "decidim_question_id"

      def translated_label
        Decidim::Forms::MapOptionPresenter.new(self).translated_label
      end
    end
  end
end
