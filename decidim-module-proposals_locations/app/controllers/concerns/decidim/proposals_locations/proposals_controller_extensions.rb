# frozen_string_literal: true

module Decidim
  module ProposalsLocations
    module ProposalsControllerExtensions
      extend ActiveSupport::Concern

      included do
        def index
          if component_settings.participatory_texts_enabled?
            @proposals = Decidim::Proposals::Proposal
                         .where(component: current_component)
                         .published
                         .not_hidden
                         .only_amendables
                         .includes(:taxonomies, :attachments, :coauthorships)
                         .order(position: :asc)
            render "decidim/proposals/proposals/participatory_texts/participatory_text"
          else
            @proposals = search.result

            @all_geocoded_proposals = @proposals.where.not(locations: nil)
            @proposals = reorder(@proposals)
            @proposals = paginate(@proposals)
            @proposals = @proposals.includes(:component, :coauthorships, :attachments)
          end
        end
      end
    end
  end
end
