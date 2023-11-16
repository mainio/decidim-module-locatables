# frozen_string_literal: true

require "spec_helper"

describe "Answer survey", type: :system do
  let(:manifest) { Decidim.find_component_manifest("surveys") }
  let!(:organization) { create(:organization) }
  let!(:participatory_space) { create :participatory_process, :published, organization: organization }

  let(:user) { create :user, :confirmed, organization: organization }

  let!(:component) do
    create(:component,
           :with_one_step,
           manifest: manifest,
           participatory_space: participatory_space)
  end

  let(:questionnaire) { create :questionnaire }
  let!(:survey) { create :survey, questionnaire: questionnaire, component: component }
  let!(:question) { create :questionnaire_question, questionnaire: questionnaire, question_type: "map_locations" }

  let(:revgeo) do
    <<~JS
      $(function() {
        // Override jQuery AJAX in order to check the request is
        // sent correctly.
        $.ajax = function(request) {
          let response = {};
          if (request.url === "https://revgeocode.search.hereapi.com/v1/revgeocode") {
            response = {
              items: [
                {
                  address: {
                    street: "Veneentekijäntie",
                    houseNumber: 4,
                    country: "FI"
                  },
                  position: {
                    lat: 11.521,
                    lng: 5.521
                  }
                }
              ]
            };
          }

          // This is a normal suggest call to:
          // https://revgeocode.search.hereapi.com/v1/revgeocode
          var deferred = $.Deferred().resolve(response);
          return deferred.promise();
        };
      });
    JS
  end

  before do
    utility = Decidim::Map.autocomplete(organization: organization)
    allow(Decidim::Map).to receive(:autocomplete).with(organization: organization).and_return(utility)
    allow(utility).to receive(:builder_options).and_return(
      api_key: "key1234"
    )

    component.update!(
      step_settings: {
        component.participatory_space.active_step.id => {
          allow_answers: true,
          allow_unregistered: true
        }
      },
      settings: { starts_at: 1.week.ago, ends_at: 1.day.from_now }
    )

    switch_to_host(organization.host)
    login_as user, scope: :user
    visit main_component_path(component)
    page.execute_script(revgeo)
  end

  context "when answering type: \"map\" -question" do
    context "when configurated for multiple locations" do
      it "allows submitting form with single location" do
        Decidim::Forms::Question.last.update(map_configuration: "multiple")
        find("[data-decidim-map]").click
        expect(page).to have_css(".leaflet-marker-draggable", count: 1)
        check "questionnaire_tos_agreement"
        click_button "Submit"
        expect(page).to have_content("This action cannot be undone and you will not be able to edit your answers. Are you sure?")
        click_link "OK"
        expect(page).to have_content("Already answered")
        expect(page).to have_content("You have already answered this form.")
        expect(Decidim::Forms::Answer.last.locations.count).to eq(1)
      end

      it "allows submitting form with multiple locations when map is configured for multiple locations" do
        Decidim::Forms::Question.last.update(map_configuration: "multiple")
        find("[data-decidim-map]").click
        find("[data-decidim-map]").click(x: 10, y: 10)
        expect(page).to have_css(".leaflet-marker-draggable", count: 2)
        check "questionnaire_tos_agreement"
        click_button "Submit"
        expect(page).to have_content("This action cannot be undone and you will not be able to edit your answers. Are you sure?")
        click_link "OK"
        expect(page).to have_content("Already answered")
        expect(page).to have_content("You have already answered this form.")
        expect(Decidim::Forms::Answer.last.locations.count).to eq(2)
      end
    end

    context "when configurated for single location" do
      it "allows submitting form with single location" do
        Decidim::Forms::Question.last.update(map_configuration: "single")
        find("[data-decidim-map]").click
        expect(page).to have_css(".leaflet-marker-draggable", count: 1)
        check "questionnaire_tos_agreement"
        click_button "Submit"
        expect(page).to have_content("This action cannot be undone and you will not be able to edit your answers. Are you sure?")
        click_link "OK"
        expect(page).to have_content("Already answered")
        expect(page).to have_content("You have already answered this form.")
        expect(Decidim::Forms::Answer.last.locations.count).to eq(1)
      end

      it "only allows submitting single location" do
        Decidim::Forms::Question.last.update(map_configuration: "single")
        visit main_component_path(component)
        page.execute_script(revgeo)

        find("[data-decidim-map]").click
        expect(page).to have_css(".leaflet-marker-draggable", count: 1)
        find("[data-decidim-map]").click(x: 20, y: 40)
        expect(page).to have_css(".leaflet-marker-draggable", count: 1)
        check "questionnaire_tos_agreement"
        click_button "Submit"
        expect(page).to have_content("This action cannot be undone and you will not be able to edit your answers. Are you sure?")
        click_link "OK"
        expect(page).to have_content("Already answered")
        expect(page).to have_content("You have already answered this form.")
        expect(Decidim::Forms::Answer.last.locations.count).to eq(1)
      end
    end
  end
end
