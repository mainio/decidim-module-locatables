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
      let(:question1) { create(:questionnaire_question, question_type: "map_locations", questionnaire: questionnaire) }

      let(:answer_options) { create_list(:answer_option, 5, question: question2) }
      let(:answer_option_ids) { answer_options.pluck(:id).map(&:to_s) }
      let(:matrix_rows) { create_list(:question_matrix_row, 3, question: question2) }
      let(:matrix_row_ids) { matrix_rows.pluck(:id).map(&:to_s) }
      let(:form_params) do
        {
          responses: [
            {
              locations: locations,
              question_id: question1.id
            }
          ],
          tos_agreement: 1
        }
      end
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
  end
end
