# frozen_string_literal: true

require "spec_helper"

describe "MapRender" do
  let(:user) { create(:user, :admin, :confirmed) }
  let(:organization) { user.organization }
  let!(:participatory_space) { create(:participatory_process, :published, organization:) }

  let!(:accountability_component) { create(:accountability_component, organization:, participatory_space:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when creating a result" do
    it "allows adding locations with a map" do
      visit decidim.root_path
      click_on "Admin dashboard"
      click_on "Processes"
      find(".action-icon--new").click
      click_on "Accountability"
      click_on "New result"
      scroll_to(".type-locations-wrapper")
      expect(page).to have_css("#result_has_location")
      find_by_id("result_has_location").click
      expect(page).to have_css("[data-decidim-map]")
    end
  end
end
