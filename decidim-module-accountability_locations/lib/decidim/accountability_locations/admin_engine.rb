# frozen_string_literal: true

module Decidim
  module AccountabilityLocations
    # This is the engine that runs on the public interface of `AccountabilityLocations`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::AccountabilityLocations::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        # resources :accountability_locations do
        #   collection do
        #     resources :exports, only: [:create]
        #   end
        # end
        # root to: "accountability_locations#index"
      end

      def load_seed
        nil
      end
    end
  end
end
