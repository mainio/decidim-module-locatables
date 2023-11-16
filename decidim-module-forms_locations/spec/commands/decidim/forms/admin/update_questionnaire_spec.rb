# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    module Admin
      describe UpdateQuestionnaire do
        let(:current_organization) { create(:organization) }
        let(:participatory_process) { create(:participatory_process, organization: current_organization) }
        let(:questionnaire) { create(:questionnaire, questionnaire_for: participatory_process) }
        let(:user) { create(:user, organization: current_organization) }
        let(:published_at) { nil }
        let(:form_params) do
          {
            "title" => {
              "en" => "Title",
              "ca" => "Title",
              "es" => "Title"
            },
            "tos" => {
              "en" => "<p>TOS</p>",
              "ca" => "<p>TOS</p>",
              "es" => "<p>TOS</p>"
            },
            "description" => {
              "en" => "<p>Content</p>",
              "ca" => "<p>Contingut</p>",
              "es" => "<p>Contenido</p>"
            },
            "questions" => {
              "0" => {
                "body" => {
                  "en" => "Pick location",
                  "ca" => "Triar la ubicació",
                  "es" => "Elegir ubicación"
                },
                "position" => "0",
                "question_type" => "map_locations",
                "map_configuration" => "single",
                "default_latitude" => "2",
                "default_longitude" => "1"
              }
            },
            "published_at" => published_at
          }
        end
        let(:form) do
          QuestionnaireForm.from_params(
            questionnaire: form_params
          ).with_context(
            current_organization: current_organization
          )
        end
        let(:command) { described_class.new(form, questionnaire, user) }

        describe "when the form is invalid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't update the questionnaire" do
            expect(questionnaire).not_to receive(:update!)
            command.call
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "updates the questionnaire" do
            command.call
            questionnaire.reload

            expect(questionnaire.description["en"]).to eq("<p>Content</p>")
            expect(questionnaire.questions.length).to eq(1)

            expect(questionnaire.questions[0].question_type).to eq("map_locations")
            expect(questionnaire.questions[0].map_configuration).to eq("single")
            expect(questionnaire.questions[0].default_latitude).to eq(2)
            expect(questionnaire.questions[0].default_longitude).to eq(1)
          end
        end

        describe "when the questionnaire has an existing question" do
          let!(:question) { create(:questionnaire_question, questionnaire: questionnaire) }

          context "and the question should be removed" do
            let(:form_params) do
              {
                "title" => {
                  "en" => "Title",
                  "ca" => "Title",
                  "es" => "Title"
                },
                "description" => {
                  "en" => "<p>Content</p>",
                  "ca" => "<p>Contingut</p>",
                  "es" => "<p>Contenido</p>"
                },
                "tos" => {
                  "en" => "<p>TOS</p>",
                  "ca" => "<p>TOS</p>",
                  "es" => "<p>TOS</p>"
                },
                "questions" => [
                  {
                    "id" => question.id,
                    "body" => question.body,
                    "position" => 0,
                    "question_type" => "map_locations",
                    "map_config" => "single",
                    "default_latitude" => "2",
                    "default_longitude" => "1",
                    "deleted" => "true"
                  }
                ]
              }
            end

            it "deletes the questionnaire question" do
              command.call
              questionnaire.reload

              expect(questionnaire.questions.length).to eq(0)
            end
          end
        end
      end
    end
  end
end
