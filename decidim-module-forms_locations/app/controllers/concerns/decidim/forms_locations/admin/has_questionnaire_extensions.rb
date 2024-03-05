# frozen_string_literal: true

module Decidim
  module FormsLocations
    module Admin
      module HasQuestionnaireExtensions
        extend ActiveSupport::Concern

        included do
          helper Decidim::FormsLocations::Admin::ApplicationHelperExtensions

          helper_method :blank_location_option

          private

          def blank_location_option
            @blank_location_option ||= Admin::LocationOptionForm.new
          end

          def location_options
            respond_to do |format|
              format.json do
                question_id = params["id"]
                question = Question.find_by(id: question_id)
                if question.present?
                  render json: question.location_options.map { |location_option|
                    LocationOptionPresenter.new(location_option).as_json
                  }
                end
              end
            end
          end

          def location_options_url(params)
            url_for([questionnaire.questionnaire_for, { action: :location_options, format: :json, **params }])
          end
        end
      end
    end
  end
end
