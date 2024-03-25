# frozen_string_literal: true

module Decidim
  module FormsLocations
    module AnswerChoiceFormExtensions
      extend ActiveSupport::Concern

      included do
        attribute :geojson, JSON
      end
    end
  end
end
