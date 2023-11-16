# frozen_string_literal: true

module Decidim
  module ProposalsLocations
    # This is the engine that runs on the public interface of `locations`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::ProposalsLocations::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      def load_seed
        nil
      end
    end
  end
end
