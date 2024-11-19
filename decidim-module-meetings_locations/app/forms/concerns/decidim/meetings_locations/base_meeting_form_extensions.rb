# frozen_string_literal: true

module Decidim
  module MeetingsLocations
    module BaseMeetingFormExtensions
      extend ActiveSupport::Concern

      included do
        def needs_address?
          (in_person_meeting? || hybrid_meeting?) && !Decidim::Map.autocomplete(organization: current_organization).present?
        end
      end
    end
  end
end
