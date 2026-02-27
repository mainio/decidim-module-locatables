# frozen_string_literal: true

module Decidim
  module AccountabilityLocations
    module Admin
      module CreateResultExtensions
        extend ActiveSupport::Concern
        include Decidim::Locations::LocationsCommand

        included do
          def run_after_hooks
            link_meetings
            link_proposals
            link_projects
            notify_proposal_followers
            update_locations(result, @form)
          end
        end
      end
    end
  end
end
