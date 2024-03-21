# frozen_string_literal: true

class AddGeojsonToAnswerChoices < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_forms_answer_choices, :geojson, :jsonb
  end
end
