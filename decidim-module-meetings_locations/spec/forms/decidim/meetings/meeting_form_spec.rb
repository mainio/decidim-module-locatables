# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe MeetingForm do
    subject(:form) { described_class.from_params(attributes).with_context(context) }

    let(:organization) { create(:organization, available_locales: [:en]) }
    let(:context) do
      {
        current_organization: organization,
        current_component: current_component,
        current_participatory_space: participatory_process
      }
    end
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "meetings" }
    let(:title) { Faker::Lorem.sentence(word_count: 1) }
    let(:description) { Faker::Lorem.sentence(word_count: 3) }
    let(:short_description) { Faker::Lorem.sentence(word_count: 1) }
    let(:location) { Faker::Lorem.sentence(word_count: 3) }
    let(:location_hints) { Faker::Lorem.sentence(word_count: 3) }
    let(:address) { nil }
    let(:latitude) { 40.1234 }
    let(:longitude) { 2.1234 }
    let(:start_time) { 2.days.from_now }
    let(:end_time) { 2.days.from_now + 4.hours }
    let(:parent_scope) { create(:scope, organization: organization) }
    let(:scope) { create(:subscope, parent: parent_scope) }
    let(:scope_id) { scope.id }
    let(:category) { create :category, participatory_space: participatory_process }
    let(:category_id) { category.id }
    let(:private_meeting) { false }
    let(:transparent) { true }
    let(:type_of_meeting) { "in_person" }
    let(:registration_type) { "on_this_platform" }
    let(:available_slots) { 0 }
    let(:registration_url) { "http://decidim.org" }
    let(:online_meeting_url) { "http://decidim.org" }
    let(:iframe_embed_type) { "none" }
    let(:registration_terms) { Faker::Lorem.sentence(word_count: 3) }
    let(:attributes) do
      {
        decidim_scope_id: scope_id,
        decidim_category_id: category_id,
        title: title,
        description: description,
        short_description: short_description,
        location: location,
        location_hints: location_hints,
        address: address,
        start_time: start_time,
        end_time: end_time,
        private_meeting: private_meeting,
        transparent: transparent,
        type_of_meeting: type_of_meeting,
        online_meeting_url: online_meeting_url,
        registration_type: registration_type,
        available_slots: available_slots,
        registration_terms: registration_terms,
        registrations_enabled: true,
        registration_url: registration_url,
        iframe_embed_type: iframe_embed_type
      }
    end

    describe "when map services are available" do
      it "doesn't validate address" do
        expect(subject).to be_valid
      end
    end

    describe "when map services are unavailable" do
      it "validates address" do
        allow(Decidim::Map).to receive(:autocomplete)

        expect(subject).not_to be_valid
      end
    end
  end
end
