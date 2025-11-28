# frozen_string_literal: true

require "decidim/forms_locations/admin"
require "decidim/forms_locations/engine"
require "decidim/forms_locations/admin_engine"

module Decidim
  # This namespace holds the logic of the `FormsLocations` component. This component
  # allows users to create forms_locations in a participatory space.
  module FormsLocations
    autoload :QuestionTypeExtensions, "decidim/forms_locations/question_type_extensions"
    autoload :MapOptionType, "decidim/forms_locations/map_option_type"
  end
end
