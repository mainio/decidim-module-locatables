# frozen_string_literal: true

module Decidim
  module Forms
    #
    # Decorator for location_options
    #
    class LocationOptionPresenter < SimpleDelegator
      def as_json(*_args)
        { id: id, title: title, body: body }
      end
    end
  end
end
