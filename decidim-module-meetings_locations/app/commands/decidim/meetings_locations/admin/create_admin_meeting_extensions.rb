# frozen_string_literal: true

module Decidim
  module MeetingsLocations
    module Admin
      module CreateAdminMeetingExtensions
        extend ActiveSupport::Concern
        include Decidim::Locations::LocationsCommand

        included do
          def run_after_hooks
            create_services!
            create_follow_form_resource(form.current_user)

            update_locations(resource, @form)
          end
        end
      end
    end
  end
end
