# frozen_string_literal: true

class CreateDecidimFormsMapOptions < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_forms_map_options do |t|
      t.references :decidim_question, index: { name: "index_decidim_forms_map_options_question_id" }
      t.jsonb :label
      t.jsonb :shape
      t.string :color, default: "#000000", null: false
    end
  end
end
