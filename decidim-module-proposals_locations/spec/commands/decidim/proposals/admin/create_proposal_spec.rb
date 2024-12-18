# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe CreateProposal do
        let!(:organization) { create(:organization) }
        let!(:proposal_component) { create(:proposal_component, :with_geocoding_enabled, organization:) }
        let!(:author) { create(:user, :admin, organization:) }
        let!(:form_klass) { ProposalForm }

        let(:title) { { en: "A reasonable proposal title" } }
        let(:body) { { en: "A reasonable proposal body" } }
        let(:address) { "Rue Galilée" }
        let(:latitude) { 46.611057 }
        let(:longitude) { 0.335462 }
        let(:form_params) do
          {
            title:,
            body:,
            locations:
          }
        end

        let(:locations) do
          [
            {
              address:,
              latitude:,
              longitude:,
              shape: "Point",
              geojson:
              '{"type":"Feature",
              "geometry":{"type":"Point",
              "coordinates":[60.25013831397032, 25.11058330535889]}}'
            }
          ]
        end

        let(:form) do
          form_klass.from_params(
            form_params
          ).with_context(
            current_organization: organization,
            current_participatory_space: proposal_component.participatory_space,
            current_component: proposal_component,
            current_user: author
          )
        end

        let(:command) do
          described_class.new(form)
        end

        context "when one location is provided" do
          it "adds single" do
            command.call

            expect(
              Decidim::Proposals::Proposal.first.locations.order(:id).map do |loc|
                loc.attributes.transform_keys(&:to_sym).slice(:address, :latitude, :longitude, :shape, :geojson)
              end
            ).to eq(locations)
          end

          it "gives no errors" do
            expect { command.call }.to broadcast(:ok)
          end

          it "only adds 1 location" do
            command.call

            expect(Decidim::Proposals::Proposal.first.locations.count).to eq(1)
          end
        end

        context "when two locations are provided" do
          let(:locations) do
            [
              {
                address:,
                latitude:,
                longitude:,
                shape: "Point",
                geojson:
                '{"type":"Feature",
                "geometry":{"type":"Point",
                "coordinates":[60.25013831397032, 25.11058330535889]}}'
              },
              {
                address: "Test street 2",
                latitude: 12.293847,
                longitude: 33.281234,
                shape: "Point",
                geojson:
                '{"type":"Feature",
                "geometry":{"type":"Point",
                "coordinates":[12.293847, 33.281234]}}'
              }
            ]
          end

          it "adds both locations" do
            command.call

            expect(
              Decidim::Proposals::Proposal.first.locations.order(:id).map do |loc|
                loc.attributes.transform_keys(&:to_sym).slice(:address, :latitude, :longitude, :shape, :geojson)
              end
            ).to eq(locations)
          end

          it "gives no errors" do
            expect { command.call }.to broadcast(:ok)
          end

          it "adds exactly 2 locations" do
            command.call

            expect(Decidim::Proposals::Proposal.first.locations.count).to eq(2)
          end
        end
      end
    end
  end
end
