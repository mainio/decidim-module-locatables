# frozen_string_literal: true

require "spec_helper"

describe "map render", type: :system do
  let(:user) { create(:user, :confirmed) }
  let(:organization) { user.organization }
  let!(:proposal_component) { create(:proposal_component, :with_geocoding_enabled, :with_creation_enabled, :published, organization: organization) }

  context "when map provided" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user

      visit main_component_path(proposal_component)
      click_link "New proposal"
      fill_in "Title", with: "Example proposal for test"
      fill_in "Body", with: "Example body text for test"
      click_button "Continue"
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

  context "when map not provided" do
    before do
      allow(Decidim::Map).to receive(:autocomplete)

      switch_to_host(organization.host)
      login_as user, scope: :user

      visit main_component_path(proposal_component)
      click_link "New proposal"
      fill_in "Title", with: "Example proposal for test"
      fill_in "Body", with: "Example body text for test"
      click_button "Continue"
    end

    context "when creating a proposal, geocoding enabled" do
      it "doesn't render a map" do
        expect(page).not_to have_selector("#proposal_has_location")
        expect(page).not_to have_selector("[data-decidim-map]", visible: :all)
      end
    end
  end
end
