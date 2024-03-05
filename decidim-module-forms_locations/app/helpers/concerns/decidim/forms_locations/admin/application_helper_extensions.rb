# frozen_string_literal: true

module Decidim
  module FormsLocations
    module Admin
      module ApplicationHelperExtensions
        extend ActiveSupport::Concern

        included do
          def tabs_id_for_question_location_option(question, location_option)
            "questionnaire_question_#{question.to_param}_location_option_#{location_option.to_param}"
          end
        end
      end
    end
  end
end
