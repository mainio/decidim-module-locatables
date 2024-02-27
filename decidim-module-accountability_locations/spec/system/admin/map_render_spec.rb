# frozen_string_literal: true

require "spec_helper"

describe "admin map render", type: :system do
  let(:user) { create(:user, :admin, :confirmed) }
  let(:organization) { user.organization }
  let!(:participatory_space) { create :participatory_process, :published, organization: organization }

  let!(:accountability_component) { create(:accountability_component, organization: organization, participatory_space: participatory_space) }

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
      expect(page).to have_selector("#result_has_location")
      find("#result_has_location").click
      scroll_to("[data-decidim-map]")
      expect(page).to have_selector("[data-decidim-map]")
    end
  end
end
