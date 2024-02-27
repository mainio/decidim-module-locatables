# frozen_string_literal: true

require "spec_helper"

describe "admin map render", type: :system do
  let(:user) { create(:user, :admin, :confirmed) }
  let(:organization) { user.organization }
  let!(:meeting_component) { create(:meeting_component, :with_creation_enabled, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when creating a meeting" do
    it "allows adding locations with a map" do
      visit decidim.root_path
      find("nav.topbar__dropmenu").click
      click_link "Admin dashboard"
      click_link "Processes"
      find(".action-icon--new").click
      click_link "Meetings"
      click_link "New meeting"
      expect(page).to have_selector("[data-decidim-map]", visible: :hidden)
      find("#meeting_type_of_meeting").find("option[value='in_person']").click
      expect(page).to have_selector("[data-decidim-map]")
    end
  end
end
