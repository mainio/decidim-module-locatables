# frozen_string_literal: true

module Decidim
  module AccountabilityLocations
    module Admin
      module UpdateResultExtensions
        extend ActiveSupport::Concern
        include Decidim::Locations::LocationsCommand

        included do
          def run_after_hooks
            link_proposals
            link_meetings
            link_projects
            send_notifications if should_notify_followers?

            update_locations(result, @form)
          end
        end
      end
    end
  end
end
