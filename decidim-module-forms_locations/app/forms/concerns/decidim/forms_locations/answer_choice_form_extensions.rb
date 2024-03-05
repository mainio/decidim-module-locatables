# frozen_string_literal: true

module Decidim
  module FormsLocations
    module AnswerChoiceFormExtensions
      extend ActiveSupport::Concern

      included do
        attribute :location_option_id, Integer

        validates :location_option_id, presence: true
      end
    end
  end
end
