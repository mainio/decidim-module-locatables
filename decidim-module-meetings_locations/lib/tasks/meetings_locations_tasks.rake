# frozen_string_literal: true

namespace :decidim do
  namespace :meetings_locations do
    desc "Transfers meetings' addresses to locations"
    task transfer_addresses: :environment do
      meetings = Decidim::Meetings::Meeting.ids
      locations = Decidim::Locations::Location.pluck(:decidim_locations_locatable_id)

      meetings -= locations

      Decidim::Meetings::Meeting.where(id: meetings).each do |transfer|
        next if transfer.latitude.nil? && transfer.longitude.nil?

        Decidim::Locations::Location.create!(
          address: transfer.address,
          latitude: transfer.latitude,
          longitude: transfer.longitude,
          decidim_locations_locatable_type: "Decidim::Meetings::Meeting",
          decidim_locations_locatable_id: transfer.id
        )
      end
    end
  end
end
