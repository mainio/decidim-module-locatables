# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module FormsLocations
    module QuestionTypeExtensions
      extend ActiveSupport::Concern

      included do
        field :map_options, [Decidim::FormsLocations::MapOptionType, { null: true }], "List of map options", null: false
      end
    end
  end
end
