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
  let!(:question) { create :questionnaire_question, mandatory: mandatory, questionnaire: questionnaire, question_type: question_type }

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

  def add_marker(latitude: 11.521, longitude: 5.521)
    find('div[title="Draw Marker"] a').click
    marker_add = <<~JS
      var map = $(".picker-wrapper [data-decidim-map]").data("map");
      var loc = L.latLng(#{latitude}, #{longitude});
      map.fire("click", { latlng: loc });
      map.panTo(loc);
    JS
    sleep 1
    page.execute_script(marker_add)
    find("div.leaflet-pm-actions-container a.leaflet-pm-action.action-cancel").click
    sleep 1
  end

  context "when question type map_locations" do
    let(:question_type) { "map_locations" }
    let(:mandatory) { false }

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

    context "when answering question" do
      context "when configurated for multiple locations" do
        it "allows submitting form with single location" do
          Decidim::Forms::Question.first.update(map_configuration: "multiple")
          add_marker
          expect(page).to have_css(".leaflet-marker-icon", count: 1)
          check "questionnaire_tos_agreement"
          click_button "Submit"
          expect(page).to have_content("This action cannot be undone and you will not be able to edit your answers. Are you sure?")
          click_link "OK"
          expect(page).to have_content("Already answered")
          expect(page).to have_content("You have already answered this form.")
          expect(Decidim::Forms::Answer.first.locations.count).to eq(1)
        end

        it "allows submitting form with multiple locations when map is configured for multiple locations" do
          Decidim::Forms::Question.first.update(map_configuration: "multiple")
          add_marker
          add_marker(latitude: 11.621, longitude: 5.621)
          expect(page).to have_css(".leaflet-marker-icon", count: 2)
          check "questionnaire_tos_agreement"
          click_button "Submit"
          expect(page).to have_content("This action cannot be undone and you will not be able to edit your answers. Are you sure?")
          click_link "OK"
          expect(page).to have_content("Already answered")
          expect(page).to have_content("You have already answered this form.")
          expect(Decidim::Forms::Answer.first.locations.count).to eq(2)
        end
      end

      context "when configurated for single location" do
        it "allows submitting form with single location" do
          Decidim::Forms::Question.first.update(map_configuration: "single")
          add_marker
          expect(page).to have_css(".leaflet-marker-icon", count: 1)
          check "questionnaire_tos_agreement"
          click_button "Submit"
          expect(page).to have_content("This action cannot be undone and you will not be able to edit your answers. Are you sure?")
          click_link "OK"
          expect(page).to have_content("Already answered")
          expect(page).to have_content("You have already answered this form.")
          expect(Decidim::Forms::Answer.first.locations.count).to eq(1)
        end

        it "only allows submitting single location" do
          Decidim::Forms::Question.first.update(map_configuration: "single")
          visit main_component_path(component)
          page.execute_script(revgeo)

          add_marker
          add_marker(latitude: 11.621, longitude: 5.621)
          expect(page).to have_css(".leaflet-marker-icon", count: 1)
          check "questionnaire_tos_agreement"
          click_button "Submit"
          expect(page).to have_content("This action cannot be undone and you will not be able to edit your answers. Are you sure?")
          click_link "OK"
          expect(page).to have_content("Already answered")
          expect(page).to have_content("You have already answered this form.")
          expect(Decidim::Forms::Answer.first.locations.count).to eq(1)
        end
      end
    end
  end

  context "when question type select_locations" do
    let(:question_type) { "select_locations" }
    let!(:answer_options) { create_list(:answer_option, 2, question: question) }
    let!(:answer_option_ids) { answer_options.pluck(:id).map(&:to_s) }
    let(:mandatory) { true }

    before do
      Decidim::Forms::Question.first.answer_options.first.update(
        geojson: '{"type":"Feature","geometry":{"type":"Point","coordinates":[12.12345,5.12345]}}'
      )
      Decidim::Forms::Question.first.answer_options.second.update(
        geojson: '{"type":"Feature","geometry":{"type":"Point","coordinates":[12.12346,5.12346]}}'
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
    end

    after do
      expect_no_js_errors

      # Reset the routes back to original
      Rails.application.reload_routes!
    end

    context "when mandatory question" do
      it "must have a pick" do
        expect(page).to have_css("[data-decidim-map]")
        expect(page).to have_css(".leaflet-marker-icon")

        expect(page).to have_content("ASDDASASDASDASD")
      end
    end
  end
end
