# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :accountability_locations_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :accountability_locations).i18n_name }
    participatory_space { create(:participatory_process, :with_steps) }
  end

  # Add engine factories here
end
