# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Accountability
    module Admin
      describe UpdateResult do
        let!(:organization) { create(:organization) }
        let!(:accountability_component) { create(:accountability_component, organization: organization) }
        let!(:result) { create(:result) }
        let!(:author) { create(:user, :admin, organization: organization) }
        let!(:form_klass) { ResultForm }

        let(:title) { { en: "A reasonable result title" } }
        let(:description) { { en: "A reasonable result_description" } }
        let(:address) { "Rue Galilée" }
        let(:latitude) { 46.611057 }
        let(:longitude) { 0.335462 }
        let(:form_params) do
          {
            title: title,
            description: description,
            locations: locations,
            start_date: Time.current,
            end_date: 2.weeks.from_now
          }
        end

        let(:locations) do
          [
            {
              address: address,
              latitude: latitude,
              longitude: longitude,
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
            current_participatory_space: accountability_component.participatory_space,
            current_component: accountability_component,
            current_user: author
          )
        end

        let(:command) do
          described_class.new(form, result)
        end

        context "when one location is provided" do
          it "adds single" do
            command.call

            expect(
              result.locations.first.attributes.transform_keys(&:to_sym).slice(:address, :latitude, :longitude, :shape, :geojson)
            ).to eq(locations.first)
          end

          it "gives no errors" do
            expect { command.call }.to broadcast(:ok)
          end

          it "only adds 1 location" do
            command.call

            expect(result.locations.count).to eq(1)
          end
        end

        context "when two locations are provided" do
          let(:locations) do
            [
              {
                address: address,
                latitude: latitude,
                longitude: longitude,
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
              result.locations.order(:id).map do |loc|
                loc.attributes.transform_keys(&:to_sym).slice(:address, :latitude, :longitude, :shape, :geojson)
              end
            ).to eq(
              locations
            )
          end

          it "gives no errors" do
            expect { command.call }.to broadcast(:ok)
          end

          it "adds exactly 2 locations" do
            command.call

            expect(result.locations.count).to eq(2)
          end
        end

        context "when submits a form without old location" do
          let!(:loc) do
            create(
              :location,
              locatable: result,
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

          let!(:loc2) do
            create(
              :location,
              locatable: result,
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

            expect(result.locations.order(:id).map do |loc|
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
              locatable: result,
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

          let!(:loc2) do
            create(
              :location,
              locatable: result,
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

            expect(result.locations.order(:id).map do |loc|
              loc.attributes.transform_keys(&:to_sym).slice(:address, :latitude, :longitude, :shape, :geojson)
            end).to eq(
              locations
            )
          end

          context "when result has 2 locations and submit a form with a third one" do
            let!(:loc) do
              create(
                :location,
                locatable: result,
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

            let!(:loc2) do
              create(
                :location,
                locatable: result,
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

              expect(result.locations.order(:id).map do |loc|
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
                locatable: result,
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

            let!(:loc2) do
              create(
                :location,
                locatable: result,
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

            let!(:loc3) do
              create(
                :location,
                locatable: result,
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

            it "deletes all locations from the result" do
              command.call

              expect(result.locations.order(:id).map do |loc|
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
