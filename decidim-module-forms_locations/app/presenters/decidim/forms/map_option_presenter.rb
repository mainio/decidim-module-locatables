# frozen_string_literal: true

module Decidim
  module Forms
    #
    # Decorator for map_options
    #
    class AnswerOptionPresenter < SimpleDelegator
      include Decidim::TranslationsHelper

      def translated_label
        @translated_label ||= translated_attribute label
      end

      def as_json(*_args)
        { id:, label: translated_label }
      end
    end
  end
end
