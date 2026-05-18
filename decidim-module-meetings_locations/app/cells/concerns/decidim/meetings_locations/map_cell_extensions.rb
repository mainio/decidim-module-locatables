# frozen_string_literal: true

module Decidim
  module MeetingsLocations
    module MapCellExtensions
      extend ActiveSupport::Concern

      included do
        def data_for_map
          model.filter_map do |record|
            if record.is_a?(Decidim::Meetings::Meeting)
              next if record.locations.blank?
            else
              next unless record.geocoded_and_valid?
            end

            record.slice(:latitude, :longitude, :address)
                  .merge(
                    title: record.presenter.title,
                    link: resource_locator(record).path,
                    items: cell(options[:metadata_card], record).send(:items_for_map).to_json
                  )
          end
        end
      end
    end
  end
end
