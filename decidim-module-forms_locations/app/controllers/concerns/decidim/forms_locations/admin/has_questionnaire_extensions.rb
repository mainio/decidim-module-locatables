# frozen_string_literal: true

module Decidim
  module FormsLocations
    module Admin
      module HasQuestionnaireExtensions
        extend ActiveSupport::Concern

        included do
          helper_method :blank_map_option

          def map_options
            respond_to do |format|
              format.json do
                question_id = params["id"]
                question = Question.find_by(id: question_id)
                render json: question.map_options.map { |map_option| MapOptionPresenter.new(map_option).as_json } if question.present?
              end
            end
          end

          def map_options_url(params)
            url_for([questionnaire.questionnaire_for, { action: :map_options, format: :json, **params }])
          end

          private

          def blank_map_option
            @blank_map_option ||= Decidim::Forms::Admin::MapOptionForm.new
          end
        end
      end
    end
  end
end
