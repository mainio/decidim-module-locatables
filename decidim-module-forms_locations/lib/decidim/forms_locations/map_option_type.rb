# frozen_string_literal: true

module Decidim
  module FormsLocations
    class MapOptionType < Decidim::Api::Types::BaseObject
      description 'A "map tag" -option for a "tag locations" -question in a questionnaire'

      field :id, GraphQL::Types::ID, "ID of this map option", null: false
      field :label, Decidim::Core::TranslatedFieldType, "The label text that is used in the map pointer option", null: false
      field :shape, Decidim::Core::TranslatedFieldType, "The shape of the map pointer", null: false
      field :color, GraphQL::Types::String, "The color of the map pointer", null: false
    end
  end
end
