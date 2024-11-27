# frozen_string_literal: true

require "spec_helper"

describe "Map" do
  include_context "with a component"

  let(:manifest_name) { "proposals" }
  let!(:user) { create(:user, :confirmed, organization:) }
  let!(:component) do
    create(:proposal_component,
           :with_creation_enabled,
           :published,
           manifest:,
           participatory_space: participatory_process,
           settings: { new_proposal_body_template: body_template, geocoding_enabled: true })
  end
  let(:body_template) do
    { "en" => "<p>This test has <strong>many</strong> characters </p>" }
  end

  context "when map provided" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit_component
      element = find("a", text: "New proposal")
      execute_script("arguments[0].click();", element)

      fill_in :proposal_title, with: "Test proposal for map"
      click_on "Continue"
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
      let!(:component) do
        create(:proposal_component,
               :with_creation_enabled,
               :published,
               manifest:,
               participatory_space: participatory_process,
               settings: { new_proposal_body_template: body_template })
      end

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
      visit_component
    end

    context "when creating a proposal, geocoding enabled" do
      it "doesn't render a map" do
        expect(page).to have_no_css("#proposal_has_location")
        expect(page).to have_no_css("[data-decidim-map]", visible: :all)
      end
    end
  end
end
