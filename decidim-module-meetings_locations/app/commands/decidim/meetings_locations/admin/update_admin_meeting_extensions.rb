# frozen_string_literal: true

module Decidim
  module MeetingsLocations
    module Admin
      module UpdateAdminMeetingExtensions
        extend ActiveSupport::Concern
        include Decidim::Locations::LocationsCommand

        included do
          def run_after_hooks
            send_notification if should_notify_followers?
            schedule_upcoming_meeting_notification if resource.published? && start_time_changed?
            update_services!

            update_locations(resource, @form)
          end
        end
      end
    end
  end
end
