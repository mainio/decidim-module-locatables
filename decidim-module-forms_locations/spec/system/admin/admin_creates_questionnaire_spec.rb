# frozen_string_literal: true

require "spec_helper"

describe "CreateSurvey" do
  let(:manifest) { Decidim.find_component_manifest("surveys") }
  let!(:organization) { create(:organization) }
  let!(:participatory_space) { create(:participatory_process, :published, organization:) }

  let(:user) { create(:user, :admin, :confirmed, organization:) }

  let!(:component) do
    create(:component,
           manifest:,
           participatory_space:)
  end

  let(:questionnaire) { create(:questionnaire) }
  let!(:survey) { create(:survey, questionnaire:, component:) }
  let!(:question) { create(:questionnaire_question, questionnaire:) }

  context "when map is provided" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit questionnaire_edit_path
    end

    context "when question type map_locations" do
      context "when question added with \"multiple\" -map configuration to survey" do
        it "allows creation of survey" do
          find(".question--collapse", match: :first).click
          check "Mandatory"
          select("Map", from: "Type").select_option
          expect(page).to have_field("Map config", with: "multiple")
          fill_in "Latitude", with: "11"
          fill_in "Longitude", with: "13"
          click_on "Save"

          expect(page).to have_content("Survey successfully saved.")
        end
      end

      context "when question added with \"single\" -map configuration to survey" do
        it "allows creation of survey" do
          find(".question--collapse", match: :first).click
          check "Mandatory"
          select("Map", from: "Type").select_option
          select("Single", from: "Map config")
          expect(page).to have_field("Map config", with: "single")
          fill_in "Latitude", with: "11"
          fill_in "Longitude", with: "13"
          click_on "Save"

          expect(page).to have_content("Survey successfully saved.")
        end
      end
    end

    context "when question type select_locations" do
      context "when question added with 2 answer options" do
        it "allows creation of survey" do
          find(".question--collapse", match: :first).click
          select("Select locations", from: "Type").select_option
          scroll_to(:bottom)
          expect(page).to have_content("Add answer option")
          expect(page).to have_content("Answer option")
          answer_options = all(".questionnaire-question-location-option")

          answer_options.each do |option|
            within(option) do
              fill_in find("input", match: :first)["name"], with: "Lauttasaari"
              fill_in "Geojson", match: :first, with: '{"type":"Feature","geometry":{"type":"Point","coordinates":[12,5]}}'
              select("Left", from: "Tooltip direction")
            end
          end

          click_on "Save"

          expect(page).to have_content("Survey successfully saved.")
          expect(Decidim::Forms::Question.first.answer_options.count).to eq(2)
          expect(Decidim::Forms::Question.first.answer_options.first.geojson).to eq(
            '{"type":"Feature","geometry":{"type":"Point","coordinates":[12,5]}}'
          )
        end
      end

      context "when question added with 3 answer options" do
        it "allows creation of survey" do
          find(".question--collapse", match: :first).click
          select("Select locations", from: "Type").select_option
          expect(page).to have_content("Answer option")
          click_on "Add answer option"
          answer_options = all(".questionnaire-question-location-option")

          answer_options.each do |option|
            within(option) do
              fill_in find("input", match: :first)["name"], with: "Lauttasaari"
              fill_in "Geojson", match: :first, with: '{"type":"Feature","geometry":{"type":"Point","coordinates":[12,5]}}'
            end
          end

          click_on "Save"

          expect(page).to have_content("Survey successfully saved.")
          expect(Decidim::Forms::Question.first.answer_options.count).to eq(3)
          expect(Decidim::Forms::Question.first.answer_options.first.geojson).to eq(
            '{"type":"Feature","geometry":{"type":"Point","coordinates":[12,5]}}'
          )
        end
      end
    end
  end

  context "when map is not provided" do
    before do
      allow(Decidim::Map).to receive(:autocomplete)

      switch_to_host(organization.host)
      login_as user, scope: :user
      visit questionnaire_edit_path
    end

    context "when selecting a question type" do
      it "doesn't allow picking 'Map locations' or 'Select locations'" do
        find(".question--collapse", match: :first).click
        select_element = find("#questionnaire_questions_#{question.id}_question_type")
        expect(select_element).to have_css("option[value='select_locations'][disabled]")
        expect(select_element).to have_css("option[value='map_locations'][disabled]")
      end
    end
  end

  def questionnaire_edit_path
    manage_component_path(component)
  end
end
