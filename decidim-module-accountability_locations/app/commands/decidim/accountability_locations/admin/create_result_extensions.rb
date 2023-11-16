# frozen_string_literal: true

module Decidim
  module AccountabilityLocations
    module Admin
      module CreateResultExtensions
        extend ActiveSupport::Concern
        include Decidim::Locations::LocationsCommand

        included do
          def call
            return broadcast(:invalid) if @form.invalid?

            transaction do
              create_result
              link_meetings
              link_proposals
              link_projects
              notify_proposal_followers
            end

            update_locations(@result, @form)

            broadcast(:ok)
          end
        end
      end
    end
  end
end
