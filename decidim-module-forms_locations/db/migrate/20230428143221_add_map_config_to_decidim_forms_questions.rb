# frozen_string_literal: true

class AddMapConfigToDecidimFormsQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_forms_questions, :map_configuration, :jsonb
  end
end
