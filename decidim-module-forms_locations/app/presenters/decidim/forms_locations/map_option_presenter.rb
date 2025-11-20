# frozen_string_literal: true

module Decidim
  module FormsLocations
    #
    # Decorator for map_options
    #
    class AnswerOptionPresenter < SimpleDelegator
      include Decidim::TranslationsHelper

      def translated_label
        @translated_label ||= translated_attribute label
      end

      def translated_shape
        @translated_shape ||= translated_attribute shape
      end

      def as_json(*_args)
        { id:, label: translated_label, shape: translated_shape }
      end
    end
  end
end
