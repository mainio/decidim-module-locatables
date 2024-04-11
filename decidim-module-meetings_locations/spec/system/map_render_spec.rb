# frozen_string_literal: true

require "spec_helper"

describe "map render", type: :system do
  let(:user) { create(:user, :confirmed) }
  let(:organization) { user.organization }
  let!(:meeting_component) { create(:meeting_component, :with_creation_enabled, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user

    visit decidim.root_path
    click_link "Processes"
    find(".card__link").click
    click_link "Meetings"
    click_link "New meeting"
  end

  context "when map provided" do
    context "when creating a meeting" do
      it "allows adding locations with a map" do
        expect(page).to have_selector("[data-decidim-map]", visible: :hidden)
        find("#meeting_type_of_meeting").find("option[value='in_person']").click
        expect(page).to have_selector("[data-decidim-map]")
      end
    end
  end

  context "when map not provided" do
    before do
      allow(Decidim::Map).to receive(:autocomplete)

      switch_to_host(organization.host)
      login_as user, scope: :user

      visit decidim.root_path
      click_link "Processes"
      find(".card__link").click
      click_link "Meetings"
      click_link "New meeting"
    end

    context "when creating a meeting" do
      it "renders an address field instead of a map" do
        find("#meeting_type_of_meeting").find("option[value='in_person']").click
        expect(page).not_to have_selector("[data-decidim-map]")
        expect(page).to have_selector("#meeting_address")
      end
    end
  end
end
