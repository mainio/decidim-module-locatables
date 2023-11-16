# frozen_string_literal: true

module Decidim
  module AccountabilityLocations
    module ResultsControllerExtensions
      extend ActiveSupport::Concern

      included do
        def home
          @all_results = Decidim::Accountability::Result.where(component: current_component)
        end
      end
    end
  end
end
