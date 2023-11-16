# frozen_string_literal: true

module Decidim
  module FormsLocations
    module Admin
      module QuestionnaireParticipantPresenterExtensions
        extend ActiveSupport::Concern

        included do
          def completion
            with_body = sibilings.where(decidim_forms_questions: { question_type: %w(short_answer long_answer) })
                                 .where.not(body: "").count
            with_choices = sibilings.where.not("decidim_forms_questions.question_type in (?)", %w(short_answer long_answer))
                                    .where("decidim_forms_answers.id IN (SELECT decidim_answer_id FROM decidim_forms_answer_choices)").count
            with_locations = sibilings.where(decidim_forms_questions: { question_type: %w(map_locations) })
                                      .joins(:locations).uniq.count

            (with_body + with_choices + with_locations).to_f / questionnaire.questions.not_separator.not_title_and_description.count * 100
          end
        end
      end
    end
  end
end
