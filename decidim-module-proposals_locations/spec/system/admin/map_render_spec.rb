# frozen_string_literal: true

require "spec_helper"

describe "AdminMap" do
  let(:user) { create(:user, :admin, :confirmed) }
  let(:organization) { user.organization }
  let!(:proposal_component) { create(:proposal_component, :with_geocoding_enabled, :with_creation_enabled, :published, organization:) }

  context "when map provided" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user

      visit decidim.root_path
      click_on "Admin dashboard"
      click_on "Processes"
      find(".action-icon--new").click
      click_on "Proposals"
      click_on "New proposal"
    end

    context "when creating a proposal, geocoding enabled" do
      it "allows adding locations with a map" do
        expect(page).to have_css("#proposal_has_location")
        expect(page).to have_css("[data-decidim-map]", visible: :hidden)
        find_by_id("proposal_has_location").click
        expect(page).to have_css("[data-decidim-map]")
      end
    end

    context "when creating a proposal, geocoding disabled" do
      let!(:proposal_component) { create(:proposal_component, :with_creation_enabled, :published, organization:) }

      it "doesn't allow adding locations" do
        expect(page).to have_no_css("#proposal_has_location")
        expect(page).to have_no_css("[data-decidim-map]", visible: :hidden)
        expect(page).to have_no_css("[data-decidim-map]")
      end
    end
  end

  context "when map not provided" do
    before do
      allow(Decidim::Map).to receive(:autocomplete)

      switch_to_host(organization.host)
      login_as user, scope: :user

      visit decidim.root_path
      click_on "Admin dashboard"
      click_on "Processes"
      find(".action-icon--new").click
      click_on "Proposals"
      click_on "New proposal"
    end

    context "when creating a proposal, geocoding enabled" do
      it "doesn't render map" do
        expect(page).to have_no_css("#proposal_has_location")
        expect(page).to have_no_css("[data-decidim-map]", visible: :all)
      end
    end
  end
end
