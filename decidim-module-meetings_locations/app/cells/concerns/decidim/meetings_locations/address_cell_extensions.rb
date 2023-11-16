# frozen_string_literal: true

module Decidim
  module MeetingsLocations
    module AddressCellExtensions
      extend ActiveSupport::Concern

      included do
        def address
          address = Decidim::Locations::Location.where(decidim_locations_locatable_id: model.id).pluck(:address)
          count = address.count - 1

          if count.positive?
            "#{address[0]} + #{count} more"
          else
            address[0]
          end
        end
      end
    end
  end
end
