# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :meetings_locations_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :meetings_locations).i18n_name }
    manifest_name :meetings_locations
    participatory_space { create(:participatory_process, :with_steps) }
  end

  # Add engine factories here
end
