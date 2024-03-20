# frozen_string_literal: true

class AddDecidimLocationOptionToAnswerChoices < ActiveRecord::Migration[5.2]
  def change
    add_reference :decidim_forms_answer_choices, :decidim_location_option,
                  index: { name: "index_decidim_forms_answer_choices_location_option_id" },
                  foreign_key: { to_table: :decidim_forms_location_options }
    add_column :decidim_forms_answer_choices, :title, :string
  end
end
