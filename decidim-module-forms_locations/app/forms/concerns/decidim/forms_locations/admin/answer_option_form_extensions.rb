# frozen_string_literal: true

module Decidim
  module FormsLocations
    module Admin
      module AnswerOptionFormExtensions
        extend ActiveSupport::Concern

        included do
          attribute :geojson, JSON

          validates :geojson, presence: true, unless: :deleted
        end
      end
    end
  end
end
