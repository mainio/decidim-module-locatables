# frozen_string_literal: true

class AddDefaultCoordsToDecidimFormsQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_forms_questions, :default_latitude, :float, default: 0
    add_column :decidim_forms_questions, :default_longitude, :float, default: 0
  end
end
