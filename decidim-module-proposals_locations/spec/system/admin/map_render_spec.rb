# frozen_string_literal: true

require "spec_helper"

describe "admin map render", type: :system do
  let(:user) { create(:user, :admin, :confirmed) }
  let(:organization) { user.organization }
  let!(:proposal_component) { create(:proposal_component, :with_geocoding_enabled, :with_creation_enabled, :published, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user

    visit decidim.root_path
    find("nav.topbar__dropmenu").click
    click_link "Admin dashboard"
    click_link "Processes"
    find(".action-icon--new").click
    click_link "Proposals"
    click_link "New proposal"
  end

  context "when creating a proposal, geocoding enabled" do
    it "allows adding locations with a map" do
      expect(page).to have_selector("#proposal_has_location")
      expect(page).to have_selector("[data-decidim-map]", visible: :hidden)
      find("#proposal_has_location").click
      expect(page).to have_selector("[data-decidim-map]")
    end
  end

  context "when creating a proposal, geocoding disabled" do
    let!(:proposal_component) { create(:proposal_component, :with_creation_enabled, :published, organization: organization) }

    it "doesn't allow adding locations" do
      expect(page).not_to have_selector("#proposal_has_location")
      expect(page).not_to have_selector("[data-decidim-map]", visible: :hidden)
      expect(page).not_to have_selector("[data-decidim-map]")
    end
  end
end
