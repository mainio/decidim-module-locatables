# frozen_string_literal: true

class AddGeojsonToAnswerOption < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_forms_answer_options, :geojson, :jsonb
  end
end
