# frozen_string_literal: true

module Decidim
  module MeetingsLocations
    # This is the engine that runs on the public interface of `MeetingsLocations`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::MeetingsLocations::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        # resources :meetings_locations do
        #   collection do
        #     resources :exports, only: [:create]
        #   end
        # end
        # root to: "meetings_locations#index"
      end

      def load_seed
        nil
      end
    end
  end
end
