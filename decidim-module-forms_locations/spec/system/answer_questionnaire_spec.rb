# frozen_string_literal: true

require "spec_helper"

describe "AnswerSurvey" do
  let(:manifest) { Decidim.find_component_manifest("surveys") }
  let!(:organization) { create(:organization) }
  let!(:participatory_space) { create(:participatory_process, :published, organization:) }

  let(:user) { create(:user, :confirmed, organization:) }

  let!(:component) do
    create(:component,
           :with_one_step,
           manifest:,
           participatory_space:)
  end

  let(:questionnaire) { create(:questionnaire) }
  let!(:survey) { create(:survey, questionnaire:, component:) }
  let!(:question) { create(:questionnaire_question, mandatory:, questionnaire:, question_type:) }

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
      utility = Decidim::Map.autocomplete(organization:)
      allow(Decidim::Map).to receive(:autocomplete).with(organization:).and_return(utility)
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
          click_on "Submit"
          expect(page).to have_content("This action cannot be undone and you will not be able to edit your answers. Are you sure?")
          click_on "OK"
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
          click_on "Submit"
          expect(page).to have_content("This action cannot be undone and you will not be able to edit your answers. Are you sure?")
          click_on "OK"
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
          click_on "Submit"
          expect(page).to have_content("This action cannot be undone and you will not be able to edit your answers. Are you sure?")
          click_on "OK"
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
          click_on "Submit"
          expect(page).to have_content("This action cannot be undone and you will not be able to edit your answers. Are you sure?")
          click_on "OK"
          expect(page).to have_content("Already answered")
          expect(page).to have_content("You have already answered this form.")
          expect(Decidim::Forms::Answer.first.locations.count).to eq(1)
        end
      end
    end
  end

  context "when question type select_locations" do
    let(:question_type) { "select_locations" }
    let!(:answer_options) { create_list(:answer_option, 2, question:) }
    let!(:answer_option_ids) { answer_options.pluck(:id).map(&:to_s) }
    let(:mandatory) { true }

    before do
      Decidim::Forms::Question.first.answer_options.first.update(
        geojson: '{"type":"Feature","geometry":{"type":"Point","coordinates":[12.12645,5.12345]}}',
        tooltip_direction: "top"
      )
      Decidim::Forms::Question.first.answer_options.second.update(
        geojson: '{"type":"Feature","geometry":{"type":"Point","coordinates":[12.12346,5.12346]}}',
        tooltip_direction: "bottom"
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

    context "when markers are close" do
      before do
        page.driver.browser.manage.window.resize_to(1280, 1024)

        Decidim::Forms::Question.first.answer_options.first.update(
          geojson: '{"type":"Feature","geometry":{"type":"Point","coordinates":[12.123456789,5.12346]}}'
        )
        Decidim::Forms::Question.first.answer_options.second.update(
          geojson: '{"type":"Feature","geometry":{"type":"Point","coordinates":[12.123456788,5.12346]}}'
        )
      end

      it "generates a marker cluster" do
        expect(page).to have_css("[data-decidim-map]")
        expect(page).to have_css(".leaflet-marker-icon")
        zoom_out_max
        expect(page).to have_css(".marker-cluster-small")
      end

      context "when marker clicked" do
        it "shows markers separately" do
          expect(page).to have_css("[data-decidim-map]")
          expect(page).to have_css(".leaflet-marker-icon")
          zoom_out_max
          expect(page).to have_css(".marker-cluster-small")
          find(".marker-cluster-small").click
          expect(page).to have_css(".leaflet-marker-pane > img", count: 2)
        end
      end
    end

    context "when marker is clicked" do
      it "changes color to green if selected" do
        expect(page).to have_css("[data-decidim-map]")
        find("div.leaflet-tooltip", text: answer_options[0].body[:en], match: :first).click
        expect(page).to have_css('img[style*="hue-rotate(275deg)"]')
      end

      it "changes the color back to blue if unselected" do
        expect(page).to have_css("[data-decidim-map]")
        find("div.leaflet-tooltip", text: answer_options[0].body[:en], match: :first).click
        expect(page).to have_css('img[style*="hue-rotate(275deg)"]')
        find("div.leaflet-tooltip", text: answer_options[0].body[:en], match: :first).click
        expect(page).to have_no_css('img[style*="hue-rotate(275deg)"]')
      end
    end

    context "when mandatory question" do
      it "submits form when option picked" do
        expect(page).to have_css("[data-decidim-map]")
        find("div.leaflet-tooltip", text: answer_options[0].body[:en], match: :first).click
        expect(page).to have_css('img[style*="hue-rotate(275deg)"]')
        find_by_id("questionnaire_tos_agreement").click
        click_on "Submit"
        click_on "OK"
        expect(page).to have_content("Already answered")
        expect(page).to have_content("You have already answered this form.")
      end

      it "gives an error if no option picked" do
        expect(page).to have_css("[data-decidim-map]")
        find_by_id("questionnaire_tos_agreement").click
        click_on "Submit"
        click_on "OK"
        expect(page).to have_content("There was a problem answering the survey.")
      end
    end

    context "when question is not mandatory" do
      let(:mandatory) { false }

      it "submits the form with no picks" do
        expect(page).to have_css("[data-decidim-map]")
        find_by_id("questionnaire_tos_agreement").click
        click_on "Submit"
        click_on "OK"
        expect(page).to have_content("Already answered")
        expect(page).to have_content("You have already answered this form.")
      end
    end
  end
end

def zoom_out_max
  page.execute_script(
    <<~JS
      $("[data-decidim-map]").data("map").zoomOut(10)
    JS
  )
end
