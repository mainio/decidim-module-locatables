# frozen_string_literal: true

module Decidim
  module FormsLocations
    module Admin
      module ApplicationHelperExtensions
        extend ActiveSupport::Concern

        included do
          def tabs_id_for_question_map_option(question, map_option)
            "questionnaire_question_#{question.to_param}_map_option_#{map_option.to_param}"
          end
        end
      end
    end
  end
end
