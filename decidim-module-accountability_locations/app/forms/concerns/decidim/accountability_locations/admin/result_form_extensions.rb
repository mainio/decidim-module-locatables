# frozen_string_literal: true

module Decidim
  module AccountabilityLocations
    module Admin
      module ResultFormExtensions
        extend ActiveSupport::Concern

        included do
          attribute :address, String
          attribute :latitude, Integer
          attribute :longitude, Integer
        end
      end
    end
  end
end
