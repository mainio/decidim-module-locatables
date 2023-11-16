# frozen_string_literal: true

module Decidim
  module FormsLocations
    # This is the engine that runs on the public interface of `FormsLocations`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::FormsLocations::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        # resources :forms_locations do
        #   collection do
        #     resources :exports, only: [:create]
        #   end
        # end
        # root to: "forms_locations#index"
      end

      def load_seed
        nil
      end
    end
  end
end
