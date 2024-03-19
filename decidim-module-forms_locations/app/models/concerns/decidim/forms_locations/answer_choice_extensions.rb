# frozen_string_literal: true

module Decidim
  module FormsLocations
    module AnswerChoiceExtensions
      extend ActiveSupport::Concern

      included do
        attribute :geojson, :jsonb
        attribute :decidim_location_option_id, :integer

        belongs_to :location_option,
                   class_name: "LocationOption",
                   foreign_key: "decidim_location_option_id"
      end
    end
  end
end
