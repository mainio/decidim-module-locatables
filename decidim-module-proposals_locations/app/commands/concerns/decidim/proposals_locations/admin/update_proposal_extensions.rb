# frozen_string_literal: true

module Decidim
  module ProposalsLocations
    module Admin
      module UpdateProposalExtensions
        extend ActiveSupport::Concern
        include Decidim::Locations::LocationsCommand

        included do
          def call
            return broadcast(:invalid) if form.invalid?

            delete_attachment(form.attachment) if delete_attachment?

            if process_attachments?
              build_attachment
              return broadcast(:invalid) if attachment_invalid?
            end

            transaction do
              update_proposal
              update_proposal_author
              document_cleanup!(include_all_attachments: true)
              create_attachments(weight: first_attachment_weight) if process_attachments?
            end

            update_locations(@proposal, @form)

            broadcast(:ok, proposal)
          end
        end
      end
    end
  end
end
