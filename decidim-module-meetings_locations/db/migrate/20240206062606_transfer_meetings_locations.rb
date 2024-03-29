# frozen_string_literal: true

class TransferMeetingsLocations < ActiveRecord::Migration[6.1]
  def up
    Decidim::Meetings::Meeting.where.not(latitude: nil, longitude: nil).each do |location|
      Decidim::Locations::Location.create!(
        address: location["address"],
        latitude: location["latitude"],
        longitude: location["longitude"],
        shape: "Point",
        geojson: "{
          \"type\": \"Feature\",
          \"geometry\": {
            \"type\": \"Point\",
            \"coordinates\":
              [#{location["latitude"]}, #{location["longitude"]}]
          }
        }",
        decidim_locations_locatable_type: "Decidim::Meetings::Meeting",
        decidim_locations_locatable_id: location["id"]
      )
    end
  end
end
