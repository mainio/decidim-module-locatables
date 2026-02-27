# frozen_string_literal: true

module Decidim
  module MeetingsLocations
    module CreateMeetingExtensions
      extend ActiveSupport::Concern
      include Decidim::Locations::LocationsCommand

      included do
        def run_after_hooks
          create_follow_form_resource(form.current_user)
          schedule_upcoming_meeting_notification
          send_notification

          update_locations(resource, @form)
        end
      end
    end
  end
end
