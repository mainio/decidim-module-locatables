# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe AnswerForm do
      subject do
        described_class.from_params(params)
      end

      let!(:question) { create(:questionnaire_question, question_type:, mandatory:, questionnaire:) }

      let!(:questionable) { create(:dummy_resource) }
      let!(:questionnaire) { create(:questionnaire, questionnaire_for: questionable) }

      let!(:params) do
        {
          "latitude" => "27.12270204225946",
          "longitude" => "15.644531250000002",
          "locations" => {
            "x1ynlf9" => {
              "address" => "Sabha-Waddan, Sabha, Sabha, Libya",
              "latitude" => "27.12270204225946",
              "longitude" => "15.644531250000002",
              "shape" => "Point",
              "geojson" =>
              '{"type":"Feature",
              "geometry":{"type":"Point",
              "coordinates":[27.12270204225946, 15.644531250000002]}}'
            }
          },
          "address" => "",
          "question_id" => question.id
        }
      end

      context "when map_locations question type" do
        let(:question_type) { "map_locations" }

        context "when mandatory question" do
          let(:mandatory) { true }

          context "when everything is OK" do
            it { is_expected.to be_valid }
          end

          context "when parameters are missing" do
            let!(:params) do
              {
                "latitude" => "",
                "longitude" => "",
                "address" => "",
                "question_id" => question.id
              }
            end

            it { is_expected.not_to be_valid }
          end
        end

        context "when question not mandatory" do
          let(:mandatory) { false }

          context "when everything is OK" do
            it { is_expected.to be_valid }
          end

          context "when parameters are missing" do
            let!(:params) do
              {
                "latitude" => "",
                "longitude" => "",
                "address" => "",
                "question_id" => question.id
              }
            end

            it { is_expected.to be_valid }
          end
        end
      end

      context "when select_locations question type" do
        let(:question_type) { "select_locations" }
        let!(:params) do
          {
            "choices" => {
              "0" => {
                "body" => "123",
                "geojson" =>
                  '{"type":"Feature",
                  "geometry":{"type":"Point",
                  "coordinates":[27.12270204225946, 15.644531250000002]}}',
                "answer_option_id" => "123"
              }
            },
            "question_id" => question.id
          }
        end

        context "when mandatory question" do
          let(:mandatory) { true }

          context "when everything is OK" do
            it { is_expected.to be_valid }
          end

          context "when parameters are missing" do
            let!(:params) do
              {
                "question_id" => question.id
              }
            end

            it { is_expected.not_to be_valid }
          end
        end

        context "when question not mandatory" do
          let(:mandatory) { false }

          context "when everything is OK" do
            it { is_expected.to be_valid }
          end

          context "when parameters are missing" do
            let!(:params) do
              {
                "question_id" => question.id
              }
            end

            it { is_expected.to be_valid }
          end
        end
      end
    end
  end
end
