# frozen_string_literal: true

namespace :decidim do
  namespace :proposals_locations do
    desc "Transfers proposals' addresses to locations"
    task transfer_addresses: :environment do
      proposals = Decidim::Proposals::Proposal.all.ids
      locations = Decidim::Locations::Location.all.pluck(:decidim_locations_locatable_id)

      proposals -= locations

      Decidim::Proposals::Proposal.all.where(id: proposals).each do |transfer|
        next if transfer.latitude.nil? && transfer.longitude.nil?

        Decidim::Locations::Location.create!(
          address: transfer.address,
          latitude: transfer.latitude,
          longitude: transfer.longitude,
          decidim_locations_locatable_type: "Decidim::Proposals::Proposal",
          decidim_locations_locatable_id: transfer.id
        )
      end
    end
  end
end
