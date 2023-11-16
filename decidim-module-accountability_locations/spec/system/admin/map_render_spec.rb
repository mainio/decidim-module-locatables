# frozen_string_literal: true

require "spec_helper"

describe "admin map render", type: :system do
  let(:user) { create(:user, :admin, :confirmed) }
  let(:organization) { user.organization }
  let!(:accountability_component) { create(:accountability_component, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when creating a result" do
    it "allows adding locations with a map" do
      visit decidim.root_path
      find("nav.topbar__dropmenu").click
      click_link "Admin dashboard"
      click_link "Processes"
      find(".action-icon--new").click
      click_link "Accountability"
      click_link "New Result"
      expect(page).to have_selector("#model_has_location")
      expect(page).to have_selector("#map", visible: :hidden)
      find("#model_has_location").click
      expect(page).to have_selector("#map")
    end
  end
end
