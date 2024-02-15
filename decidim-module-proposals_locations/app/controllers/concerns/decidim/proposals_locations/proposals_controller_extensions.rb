# frozen_string_literal: true

module Decidim
  module ProposalsLocations
    module ProposalsControllerExtensions
      extend ActiveSupport::Concern

      included do
        def geojson
          render :geojson
        end

        def geojson_list
          Decidim::Proposals::Proposal.where(decidim_component_id: params["component_id"]).flat_map(&:locations)
        end

        helper_method :geojson_list
      end
    end
  end
end
