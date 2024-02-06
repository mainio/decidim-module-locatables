# frozen_string_literal: true

class TransferProposalsLocations < ActiveRecord::Migration[6.1]
  def up
    Decidim::Proposals::Proposal.where.not(latitude: nil, longitude: nil).each do |location|
      Decidim::Locations::Location.create!(
        address: location["address"],
        latitude: location["latitude"],
        longitude: location["longitude"],
        shape: "Marker",
        geojson: "{\"lat\":#{location["latitude"]},\"lng\":#{location["longitude"]}}",
        decidim_locations_locatable_type: "Decidim::Proposals::Proposal",
        decidim_locations_locatable_id: location["id"]
      )
    end
  end
end
