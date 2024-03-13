# frozen_string_literal: true

module Decidim
  module FormsLocations
    module Admin
      module QuestionnaireFormExtensions
        extend ActiveSupport::Concern

        included do
          attribute :address, String
        end
      end
    end
  end
end
