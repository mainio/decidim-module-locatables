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
              @proposal.attachments.destroy_all

              build_attachment
              return broadcast(:invalid) if attachment_invalid?
            end

            if process_gallery?
              build_gallery
              return broadcast(:invalid) if gallery_invalid?
            end

            transaction do
              update_proposal
              update_proposal_author
              create_gallery if process_gallery?
              create_attachment(weight: first_attachment_weight) if process_attachments?
              photo_cleanup!
            end

            update_locations(@proposal, @form)

            broadcast(:ok, proposal)
          end
        end
      end
    end
  end
end
