# frozen_string_literal: true

class AddLocationCommentConfigurationToDecidimFormsQuestions < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_forms_questions, :geojson, :jsonb
    add_column :decidim_forms_questions, :allow_comments, :boolean, default: true
  end
end
