# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Accountability
    module Admin
      describe CreateResult do
        let!(:organization) { create(:organization) }
        let!(:accountability_component) { create(:accountability_component, organization: organization) }
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
          described_class.new(form)
        end

        context "when one location is provided" do
          it "adds single" do
            command.call

            expect(
              Decidim::Accountability::Result.first.locations.order(:id).map do |loc|
                loc.attributes.transform_keys(&:to_sym).slice(:address, :latitude, :longitude, :shape, :geojson)
              end
            ).to eq(locations)
          end

          it "gives no errors" do
            expect { command.call }.to broadcast(:ok)
          end

          it "only adds 1 location" do
            command.call

            expect(Decidim::Accountability::Result.first.locations.count).to eq(1)
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
              Decidim::Accountability::Result.first.locations.order(:id).map do |loc|
                loc.attributes.transform_keys(&:to_sym).slice(:address, :latitude, :longitude, :shape, :geojson)
              end
            ).to eq(locations)
          end

          it "gives no errors" do
            expect { command.call }.to broadcast(:ok)
          end

          it "adds exactly 2 locations" do
            command.call

            expect(Decidim::Accountability::Result.first.locations.count).to eq(2)
          end
        end
      end
    end
  end
end
