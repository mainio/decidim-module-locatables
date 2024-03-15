# frozen_string_literal: true

module Decidim
  module FormsLocations
    module SurveysControllerExtensions
      extend ActiveSupport::Concern

      included do
        def all_location_options
          survey.questionnaire.questions.where(question_type: "select_locations").map(&:location_options)
        end
      end
    end
  end
end
