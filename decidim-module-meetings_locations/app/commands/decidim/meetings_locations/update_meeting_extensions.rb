# frozen_string_literal: true

module Decidim
  module MeetingsLocations
    module UpdateMeetingExtensions
      extend ActiveSupport::Concern
      include Decidim::Locations::LocationsCommand

      included do
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            update_meeting!
            send_notification if should_notify_followers?
            schedule_upcoming_meeting_notification if start_time_changed?
          end

          update_locations(@meeting, @form)

          broadcast(:ok, meeting)
        end
      end
    end
  end
end
