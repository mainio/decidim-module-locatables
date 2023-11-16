# frozen_string_literal: true

module Decidim
  module AccountabilityLocations
    module Admin
      module UpdateResultExtensions
        extend ActiveSupport::Concern
        include Decidim::Locations::LocationsCommand

        included do
          def call
            return broadcast(:invalid) if form.invalid?

            transaction do
              update_result
              link_proposals
              link_meetings
              link_projects
              send_notifications if should_notify_followers?
            end

            update_locations(@result, @form)

            broadcast(:ok)
          end
        end
      end
    end
  end
end
