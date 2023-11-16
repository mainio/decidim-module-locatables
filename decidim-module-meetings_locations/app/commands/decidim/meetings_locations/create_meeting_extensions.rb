# frozen_string_literal: true

module Decidim
  module MeetingsLocations
    module CreateMeetingExtensions
      extend ActiveSupport::Concern
      include Decidim::Locations::LocationsCommand

      included do
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            create_meeting!
            schedule_upcoming_meeting_notification
            send_notification
          end

          create_follow_form_resource(form.current_user)
          update_locations(@meeting, @form)

          broadcast(:ok, meeting)
        end
      end
    end
  end
end
