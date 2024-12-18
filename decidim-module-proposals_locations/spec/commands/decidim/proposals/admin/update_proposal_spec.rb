# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe UpdateProposal do
        let!(:organization) { create(:organization) }
        let!(:proposal_component) { create(:proposal_component, :with_geocoding_enabled, organization:) }
        let(:proposal) { create(:proposal, :official, component: proposal_component, users: [author]) }
        let!(:author) { create(:user, :admin, organization:) }
        let!(:form_klass) { Decidim::Proposals::Admin::ProposalForm }

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
              "coordinates":[46.611057, 0.335462]}}'
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
          described_class.new(form, proposal)
        end

        context "when one location is provided" do
          it "adds single" do
            command.call

            expect(
              proposal.locations.first.attributes.transform_keys(&:to_sym).slice(:address, :latitude, :longitude, :shape, :geojson)
            ).to eq(locations.first)
          end

          it "gives no errors" do
            expect { command.call }.to broadcast(:ok)
          end

          it "only adds 1 location" do
            command.call

            expect(proposal.locations.count).to eq(1)
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
                "coordinates":[46.611057, 0.335462]}}'
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
              proposal.locations.order(:id).map do |loc|
                loc.attributes.transform_keys(&:to_sym).slice(:address, :latitude, :longitude, :shape, :geojson)
              end
            ).to eq(locations)
          end

          it "gives no errors" do
            expect { command.call }.to broadcast(:ok)
          end

          it "adds exactly 2 locations" do
            command.call

            expect(proposal.locations.count).to eq(2)
          end
        end

        context "when submits a form without old location" do
          let!(:loc) do
            create(
              :location,
              locatable: proposal,
              address: "Update",
              latitude: 1.111222,
              longitude: 1.111222,
              shape: "Point",
              geojson:
              '{"type":"Feature",
              "geometry":{"type":"Point",
              "coordinates":[1.111222, 1.111222]}}'
            )
          end

          let!(:loc_two) do
            create(
              :location,
              locatable: proposal,
              address: "Delete",
              latitude: 1.121212,
              longitude: 2.2121221,
              shape: "Point",
              geojson:
              '{"type":"Feature",
              "geometry":{"type":"Point",
              "coordinates":[1.121212, 2.2121221]}}'
            )
          end

          let(:locations) do
            [
              {
                address: "Update",
                latitude: 1.111222,
                longitude: 1.111222,
                shape: "Point",
                geojson:
                '{"type":"Feature",
                "geometry":{"type":"Point",
                "coordinates":[1.111222, 1.111222]}}'
              }
            ]
          end

          it "deletes old location" do
            command.call

            expect(proposal.locations.order(:id).map do |loc|
              loc.attributes.transform_keys(&:to_sym).slice(:address, :latitude, :longitude, :shape, :geojson)
            end).to eq(
              locations
            )
          end
        end

        context "when submits a form with one old location and other modified" do
          let!(:loc) do
            create(
              :location,
              locatable: proposal,
              address: "Update",
              latitude: 1.111222,
              longitude: 1.111222,
              shape: "Point",
              geojson:
              '{"type":"Feature",
              "geometry":{"type":"Point",
              "coordinates":[1.111222, 1.111222]}}'
            )
          end

          let!(:loc_two) do
            create(
              :location,
              locatable: proposal,
              address: "Delete",
              latitude: 1.121212,
              longitude: 2.2121221,
              shape: "Point",
              geojson:
              '{"type":"Feature",
              "geometry":{"type":"Point",
              "coordinates":[1.121212, 2.2121221]}}'
            )
          end

          let(:locations) do
            [
              {
                address: "Updated",
                latitude: 2.222222,
                longitude: 2.222222,
                shape: "Point",
                geojson:
                '{"type":"Feature",
                "geometry":{"type":"Point",
                "coordinates":[2.222222, 2.222222]}}'
              },
              {
                address: "Delete",
                latitude: 1.121212,
                longitude: 2.2121221,
                shape: "Point",
                geojson:
                '{"type":"Feature",
                "geometry":{"type":"Point",
                "coordinates":[1.121212, 2.2121221]}}'
              }
            ]
          end

          it "updates existing location" do
            command.call

            expect(proposal.locations.order(:id).map do |loc|
              loc.attributes.transform_keys(&:to_sym).slice(:address, :latitude, :longitude, :shape, :geojson)
            end).to eq(
              locations
            )
          end

          context "when proposal has 2 locations and submit a form with a third one" do
            let!(:loc) do
              create(
                :location,
                locatable: proposal,
                address: "Update",
                latitude: 1.111222,
                longitude: 1.111222,
                shape: "Point",
                geojson:
                '{"type":"Feature",
                "geometry":{"type":"Point",
                "coordinates":[1.111222, 1.111222]}}'
              )
            end

            let!(:loc_two) do
              create(
                :location,
                locatable: proposal,
                address: "Delete",
                latitude: 1.121212,
                longitude: 2.2121221,
                shape: "Point",
                geojson:
                '{"type":"Feature",
                "geometry":{"type":"Point",
                "coordinates":[1.121212, 2.2121221]}}'
              )
            end

            let(:locations) do
              [
                {
                  address: "Update",
                  latitude: 1.123456,
                  longitude: 2.234567,
                  shape: "Point",
                  geojson:
                  '{"type":"Feature",
                  "geometry":{"type":"Point",
                  "coordinates":[1.123456, 2.234567]}}'
                },
                {
                  address: "Delete",
                  latitude: 1.121212,
                  longitude: 2.2121221,
                  shape: "Point",
                  geojson:
                  '{"type":"Feature",
                  "geometry":{"type":"Point",
                  "coordinates":[1.121212, 2.2121221]}}'
                },
                {
                  address: "Third",
                  latitude: 3.222222,
                  longitude: 4.121212,
                  shape: "Point",
                  geojson:
                  '{"type":"Feature",
                  "geometry":{"type":"Point",
                  "coordinates":[3.222222, 4.121212]}}'
                }
              ]
            end

            it "adds a third location" do
              command.call

              expect(proposal.locations.order(:id).map do |loc|
                loc.attributes.transform_keys(&:to_sym).slice(:address, :latitude, :longitude, :shape, :geojson)
              end).to eq(
                locations
              )
            end
          end

          context "when deleting all locations" do
            let!(:loc) do
              create(
                :location,
                locatable: proposal,
                address: "Update",
                latitude: 1.111222,
                longitude: 1.111222,
                shape: "Point",
                geojson:
                '{"type":"Feature",
                "geometry":{"type":"Point",
                "coordinates":[1.111222, 1.111222]}}'
              )
            end

            let!(:loc_two) do
              create(
                :location,
                locatable: proposal,
                address: "Delete",
                latitude: 1.121212,
                longitude: 2.2121221,
                shape: "Point",
                geojson:
                '{"type":"Feature",
                "geometry":{"type":"Point",
                "coordinates":[1.121212, 2.2121221]}}'
              )
            end

            let!(:loc_three) do
              create(
                :location,
                locatable: proposal,
                address: "Third",
                latitude: 3.222222,
                longitude: 4.121212,
                shape: "Point",
                geojson:
                '{"type":"Feature",
                "geometry":{"type":"Point",
                "coordinates":[3.222222, 4.121212]}}'
              )
            end

            let(:locations) do
              []
            end

            it "deletes all locations from the proposal" do
              command.call

              expect(proposal.locations.order(:id).map do |loc|
                loc.attributes.transform_keys(&:to_sym).slice(:address, :latitude, :longitude, :shape, :geojson)
              end).to eq(
                locations
              )
            end
          end
        end
      end
    end
  end
end
