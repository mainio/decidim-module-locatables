# frozen_string_literal: true

require "spec_helper"

describe "Map" do
  include_context "with a component"
  let(:manifest_name) { "meetings" }
  let(:user) { create(:user, :confirmed) }
  let!(:component) do
    create(:meeting_component,
           :with_creation_enabled,
           manifest:,
           participatory_space:)
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user

    visit_component
    element = find("a", text: "New meeting")
    execute_script("arguments[0].click();", element)
  end

  context "when map provided" do
    context "when creating a meeting" do
      it "allows adding locations with a map" do
        expect(page).to have_css("[data-decidim-map]", visible: :hidden)
        find_by_id("meeting_type_of_meeting").find("option[value='in_person']").click
        expect(page).to have_css("[data-decidim-map]")
      end
    end
  end

  context "when map not provided" do
    before do
      allow(Decidim::Map).to receive(:autocomplete)

      switch_to_host(organization.host)
      login_as user, scope: :user

      visit_component
      element = find("a", text: "New meeting")
      execute_script("arguments[0].click();", element)
    end

    context "when creating a meeting" do
      it "renders an address field instead of a map" do
        find_by_id("meeting_type_of_meeting").find("option[value='in_person']").click
        expect(page).to have_no_css("[data-decidim-map]")
        expect(page).to have_css("#meeting_address")
      end
    end
  end
end
