# frozen_string_literal: true

module Decidim
  module ProposalsLocations
    module UpdateProposalExtensions
      extend ActiveSupport::Concern
      include Decidim::Locations::LocationsCommand

      included do
        def call
          return broadcast(:invalid) if invalid?

          if process_attachments?
            build_attachments
            return broadcast(:invalid) if attachments_invalid?
          end

          with_events(with_transaction: true) do
            if @proposal.draft?
              update_draft
            else
              update_proposal
            end

            document_cleanup!(include_all_attachments: true)

            create_attachments(first_weight: first_attachment_weight) if process_attachments?
          end

          update_locations(@proposal, @form)

          broadcast(:ok, proposal)
        end
      end
    end
  end
end
