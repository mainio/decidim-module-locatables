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

            if process_gallery?
              build_gallery
              return broadcast(:invalid) if gallery_invalid?
            end

            transaction do
              create_proposal
              create_gallery if process_gallery?
              create_attachment(weight: first_attachment_weight) if process_attachments?
              link_author_meeeting if form.created_in_meeting?
              send_notification
            end

            update_locations(@proposal, @form)

            broadcast(:ok, proposal)
          end

          private

          attr_reader :form, :proposal, :attachment, :gallery

          def create_proposal
            @proposal = Decidim::Proposals::ProposalBuilder.create(
              attributes: attributes,
              author: form.author,
              action_user: form.current_user
            )
            @attached_to = @proposal
          end

          def attributes
            parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: form.current_organization).rewrite
            parsed_body = Decidim::ContentProcessor.parse(form.body, current_organization: form.current_organization).rewrite
            {
              title: parsed_title,
              body: parsed_body,
              category: form.category,
              scope: form.scope,
              component: form.component,
              address: form.address,
              latitude: form.latitude,
              longitude: form.longitude,
              created_in_meeting: form.created_in_meeting,
              published_at: Time.current
            }
          end
        end
      end
    end
  end
end
