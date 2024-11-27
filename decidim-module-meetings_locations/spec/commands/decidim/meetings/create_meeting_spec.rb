# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe CreateMeeting do
      let!(:organization) { create(:organization) }
      let!(:meeting_component) { create(:meeting_component, organization:) }
      let!(:author) { create(:user, :admin, organization:) }
      let!(:form_klass) { MeetingForm }

      let(:title) { { en: "A reasonable meeting title" } }
      let(:description) { { en: "A reasonable meeting description" } }
      let(:address) { "Rue Galilée" }
      let(:latitude) { 46.611057 }
      let(:longitude) { 0.335462 }
      let(:form_params) do
        {
          title:,
          description:,
          locations:,
          start_time: Time.current,
          end_time: 2.weeks.from_now,
          location: "Test location",
          registration_type: "registration_disabled",
          type_of_meeting: "in_person",
          current_user: author
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
          current_participatory_space: meeting_component.participatory_space,
          current_component: meeting_component,
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
            Decidim::Meetings::Meeting.first.locations.order(:id).map do |loc|
              loc.attributes.transform_keys(&:to_sym).slice(:address, :latitude, :longitude, :shape, :geojson)
            end
          ).to eq(
            locations
          )
        end

        it "gives no errors" do
          expect { command.call }.to broadcast(:ok)
        end

        it "only adds 1 location" do
          command.call

          expect(Decidim::Meetings::Meeting.first.locations.count).to eq(1)
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
            Decidim::Meetings::Meeting.first.locations.order(:id).map do |loc|
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

          expect(Decidim::Meetings::Meeting.first.locations.count).to eq(2)
        end
      end
    end
  end
end
