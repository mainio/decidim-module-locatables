# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe AnswerQuestionnaire do
      def tokenize(id)
        "fake-hash-for-#{id}"
      end

      let(:current_organization) { create(:organization) }
      let(:current_user) { create(:user, organization: current_organization) }
      let(:session_id) { "session-string" }
      let(:session_token) { tokenize(current_user&.id || session_id) }
      let(:remote_ip) { "1.1.1.1" }
      let(:ip_hash) { tokenize(remote_ip) }
      let(:request) do
        double(
          session: { session_id: session_id },
          remote_ip: remote_ip
        )
      end

      let(:participatory_process) { create(:participatory_process, organization: current_organization) }
      let(:questionnaire) { create(:questionnaire, questionnaire_for: participatory_process) }
      let(:question) { create(:questionnaire_question, question_type: question_type, questionnaire: questionnaire) }

      let(:form) do
        QuestionnaireForm.from_params(
          form_params
        ).with_context(
          current_organization: current_organization,
          session_token: session_token,
          ip_hash: ip_hash
        )
      end
      let(:command) { described_class.new(form, current_user, questionnaire) }

      context "when question type is map_locations" do
        let(:question_type) { "map_locations" }
        let(:locations) do
          [
            {
              address: "Example street",
              latitude: 12.0,
              longitude: 4.0,
              shape: "Point",
              geojson:
              '{"type":"Feature",
              "geometry":{"type":"Point",
              "coordinates":[12.0, 4.0]}}'
            }
          ]
        end
        let(:form_params) do
          {
            responses: [
              {
                locations: locations,
                question_id: question.id
              }
            ],
            tos_agreement: 1
          }
        end

        context "when one location is provided" do
          it "adds single" do
            command.call

            expect(Decidim::Forms::Answer.first.locations.count).to eq(1)
          end

          it "gives no errors" do
            expect { command.call }.to broadcast(:ok)
          end
        end

        context "when two locations are provided" do
          let(:locations) do
            [
              {
                address: "Example street",
                latitude: 12.0,
                longitude: 4.0,
                shape: "Point",
                geojson:
                '{"type":"Feature",
                "geometry":{"type":"Point",
                "coordinates":[12.0, 4.0]}}'
              },
              {
                address: "Test street 2",
                latitude: 12.293847,
                longitude: 33.281234,
                shape: "Point",
                geojson:
                '{"type":"Feature",
                "geometry":{"type":"Point",
                "coordinates":[12.293847, 33.281234]}}'
              }
            ]
          end

          it "adds both locations" do
            command.call

            expect(Decidim::Forms::Answer.first.locations.count).to eq(
              2
            )
          end

          it "gives no errors" do
            expect { command.call }.to broadcast(:ok)
          end
        end
      end

      context "when question type is select_locations" do
        let(:question_type) { "select_locations" }
        let(:answer_options) { create_list(:answer_option, 2, question: question) }
        let(:answer_option_ids) { answer_options.pluck(:id).map(&:to_s) }

        let(:choices) do
          [
            {
              body: "Example body",
              geojson: '{"type":"Feature",
                        "geometry":{"type":"Point",
                        "coordinates":[27.12270204225946, 15.644531250000002]}}',
              answer_option_id: answer_option_ids[0]
            }
          ]
        end
        let(:form_params) do
          {
            responses: [
              {
                choices: choices,
                question_id: question.id
              }
            ],
            tos_agreement: 1
          }
        end

        context "when one option is picked" do
          it "adds single choice" do
            command.call

            expect(Decidim::Forms::Answer.first.choices.count).to eq(1)
          end

          it "gives no errors" do
            expect { command.call }.to broadcast(:ok)
          end
        end

        context "when two options are picked" do
          let(:choices) do
            [
              {
                body: "Example body",
                geojson: '{"type":"Feature",
                          "geometry":{"type":"Point",
                          "coordinates":[27.12270204225946, 15.644531250000002]}}',
                answer_option_id: answer_option_ids[0]
              },
              {
                body: "Example body 2",
                geojson: '{"type":"Feature",
                          "geometry":{"type":"Point",
                          "coordinates":[22.12345, 12.54321]}}',
                answer_option_id: answer_option_ids[1]
              }
            ]
          end

          it "adds both locations" do
            command.call

            expect(Decidim::Forms::Answer.first.choices.count).to eq(2)
          end

          it "gives no errors" do
            expect { command.call }.to broadcast(:ok)
          end
        end
      end
    end
  end
end
