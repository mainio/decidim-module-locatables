# frozen_string_literal: true

module Decidim
  module ProposalsLocations
    module Admin
      module CreateProposalExtensions
        extend ActiveSupport::Concern
        include Decidim::Locations::LocationsCommand

        included do
          def call
            return broadcast(:invalid) if form.invalid?

            if process_attachments?
              build_attachment
              return broadcast(:invalid) if attachment_invalid?
            end

            transaction do
              create_proposal
              create_attachment(weight: first_attachment_weight) if process_attachments?
              link_author_meeeting if form.created_in_meeting?
            end

            send_notification

            update_locations(@proposal, @form)

            broadcast(:ok, proposal)
          end

          private

          attr_reader :form, :proposal, :attachment, :gallery

          def create_proposal
            @proposal = Decidim::Proposals::ProposalBuilder.create(
              attributes:,
              author: form.author,
              action_user: form.current_user
            )
            @attached_to = @proposal

            Decidim.traceability.perform_action!(:publish, @proposal, form.current_user, visibility: "all") do
              @proposal.update!(published_at: Time.current)
            end
          end

          def attributes
            parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: form.current_organization).rewrite
            parsed_body = Decidim::ContentProcessor.parse(form.body, current_organization: form.current_organization).rewrite
            {
              title: parsed_title,
              body: parsed_body,
              taxonomizations: form.taxonomizations,
              component: form.component,
              address: form.address,
              latitude: form.latitude,
              longitude: form.longitude,
              created_in_meeting: form.created_in_meeting
            }
          end
        end
      end
    end
  end
end
