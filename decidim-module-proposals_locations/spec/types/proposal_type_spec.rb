# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Proposals
    describe ProposalType, type: :graphql do
      include_context "with a graphql class type"
      let(:component) { create(:proposal_component) }
      let(:model) { create(:proposal, component: component) }
      let(:location) { create(:location, locatable: proposal, address: "Model speedway", latitude: 11.11, longitude: 10.10) }
      let(:location2) { create(:location, locatable: proposal, address: "Proposal path", latitude: 12.12, longitude: 9.9) }

      describe "locations" do
        let(:query) { "{ locations { address } }" }

        it "returns the proposal's locations" do
          expect(response["locations"]).to eq(model.locations)
        end
      end
    end
  end
end
