# frozen_string_literal: true

module Decidim
  module FormsLocations
    module Admin
      module AnswerOptionFormExtensions
        extend ActiveSupport::Concern

        included do
          attribute :geojson, JSON
          attribute :tooltip_direction, String, default: "left"
        end
      end
    end
  end
end
