# frozen_string_literal: true

class AddConfigurationsToResponseOption < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_forms_response_options, :geojson, :jsonb
    add_column :decidim_forms_response_options, :tooltip_direction, :string, default: "left"
  end
end
