# frozen_string_literal: true

module Decidim
  module MeetingsLocations
    module UpdateMeetingExtensions
      extend ActiveSupport::Concern
      include Decidim::Locations::LocationsCommand

      included do
        def call
          return broadcast(:invalid) if form.invalid?

          with_events(with_transaction: true) do
            update_meeting!
          end

          send_notification if should_notify_followers?
          schedule_upcoming_meeting_notification if start_time_changed?

          update_locations(@meeting, @form)

          broadcast(:ok, meeting)
        end
      end
    end
  end
end
