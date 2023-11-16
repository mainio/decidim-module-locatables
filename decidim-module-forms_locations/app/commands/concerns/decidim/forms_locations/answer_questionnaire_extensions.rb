# frozen_string_literal: true

module Decidim
  module FormsLocations
    module AnswerQuestionnaireExtensions
      extend ActiveSupport::Concern
      include Decidim::Locations::LocationsCommand

      included do
        def answer_questionnaire
          @main_form = @form
          @errors = nil

          Decidim::Forms::Answer.transaction(requires_new: true) do
            form.responses_by_step.flatten.select(&:display_conditions_fulfilled?).each do |form_answer|
              answer = Decidim::Forms::Answer.new(
                user: @current_user,
                questionnaire: @questionnaire,
                question: form_answer.question,
                body: form_answer.body,
                session_token: form.context.session_token,
                ip_hash: form.context.ip_hash
              )

              form_answer.selected_choices.each do |choice|
                answer.choices.build(
                  body: choice.body,
                  custom_body: choice.custom_body,
                  decidim_answer_option_id: choice.answer_option_id,
                  decidim_question_matrix_row_id: choice.matrix_row_id,
                  position: choice.position
                )
              end

              answer.save!

              update_locations(answer, form_answer)

              next unless form_answer.question.has_attachments?

              # The attachments module expects `@form` to be the form with the
              # attachments
              @form = form_answer
              @attached_to = answer

              build_attachments

              if attachments_invalid?
                @errors = true
                next
              end

              create_attachments if process_attachments?
              document_cleanup!
            end

            @form = @main_form
            raise ActiveRecord::Rollback if @errors
          end
        end
      end
    end
  end
end
