# frozen_string_literal: true

module Decidim
  module MeetingsLocations
    module BaseMeetingFormExtensions
      extend ActiveSupport::Concern

      included do
        _validators.reject! { |key, _| key == :address }
        _validate_callbacks.each do |callback|
          next unless callback.raw_filter.respond_to?(:attributes)

          _validate_callbacks.delete(callback) if callback.raw_filter.attributes == [:address]
        end
      end
    end
  end
end
