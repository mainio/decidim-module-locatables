# frozen_string_literal: true

module Decidim
  module ProposalsLocations
    module MapHelperExtensions
      extend ActiveSupport::Concern

      included do
        def has_position?(proposal)
          proposal.latitude.present? && proposal.longitude.present?
        end
      end
    end
  end
end
