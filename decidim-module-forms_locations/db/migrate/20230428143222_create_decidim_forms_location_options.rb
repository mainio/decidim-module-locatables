# frozen_string_literal: true

class CreateDecidimFormsLocationOptions < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_forms_location_options do |t|
      t.references :decidim_question, index: { name: "index_decidim_forms_location_options_question_id" }
      t.jsonb :geojson
    end
  end
end
