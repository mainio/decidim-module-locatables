# frozen_string_literal: true

module Decidim
  module MeetingsLocations
    module MeetingsMapCellExtensions
      extend ActiveSupport::Concern

      included do
        def geocoded_meetings
          @geocoded_meetings ||= meetings.where.not(locations: nil)
        end
      end
    end
  end
end
