# frozen_string_literal: true

class AddGeojsonToResponseChoices < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_forms_response_choices, :geojson, :jsonb
  end
end
