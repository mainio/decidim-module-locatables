# frozen_string_literal: true

require "spec_helper"

describe "Admin creates survey", type: :system do
  let(:manifest) { Decidim.find_component_manifest("surveys") }
  let!(:organization) { create(:organization) }
  let!(:participatory_space) { create :participatory_process, :published, organization: organization }

  let(:user) { create :user, :admin, :confirmed, organization: organization }

  let!(:component) do
    create(:component,
           manifest: manifest,
           participatory_space: participatory_space)
  end

  let(:questionnaire) { create :questionnaire }
  let!(:survey) { create :survey, questionnaire: questionnaire, component: component }
  let!(:question) { create :questionnaire_question, questionnaire: questionnaire }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit questionnaire_edit_path
  end

  context "when type: \"map\" question added with \"multiple\" -map configuration to survey" do
    it "allows creation of survey" do
      find(".question--collapse", match: :first).click
      check "Mandatory"
      select("Map", from: "Type").select_option
      expect(page).to have_field("Map config", with: "multiple")
      fill_in "Default latitude", with: "11"
      fill_in "Default longitude", with: "13"
      click_button "Save"

      expect(page).to have_content("Survey successfully saved.")
    end
  end

  context "when type: \"map\" question added with \"single\" -map configuration to survey" do
    it "allows creation of survey" do
      find(".question--collapse", match: :first).click
      check "Mandatory"
      select("Map", from: "Type").select_option
      select("Single", from: "Map config")
      expect(page).to have_field("Map config", with: "single")
      fill_in "Default latitude", with: "11"
      fill_in "Default longitude", with: "13"
      click_button "Save"

      expect(page).to have_content("Survey successfully saved.")
    end
  end

  def questionnaire_edit_path
    manage_component_path(component)
  end
end
