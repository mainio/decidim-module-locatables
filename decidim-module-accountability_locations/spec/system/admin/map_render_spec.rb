# frozen_string_literal: true

require "spec_helper"

describe "admin map render", type: :system do
  let(:user) { create(:user, :admin, :confirmed) }
  let(:organization) { user.organization }
  let!(:participatory_space) { create :participatory_process, :published, organization: }

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
      find("#result_decidim_category_id").click
      expect(page).to have_selector("[data-decidim-map]")
    end
  end
end
