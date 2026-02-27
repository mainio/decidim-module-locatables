# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

# Inside the development app, the relative require has to be one level up, as
# the Gemfile is copied to the development_app folder (almost) as is.
base_path = ""
base_path = "../" if File.basename(__dir__) == "development_app"
require_relative "#{base_path}lib/decidim/locatables/version"

DECIDIM_VERSION = Decidim::Locatables.decidim_version

gem "decidim", DECIDIM_VERSION
gem "decidim-locatables", path: "."
gem "decidim-locations", github: "mainio/decidim-module-locations", branch: "release/0.28-stable"

gem "bootsnap", "~> 1.4"

# This is a temporary fix for: https://github.com/rails/rails/issues/54263
# Without this downgrade Activesupport will give error for missing Logger
gem "concurrent-ruby", "1.3.4"

gem "puma", ">= 5.0.0"
gem "uglifier", "~> 4.1"

gem "nokogiri", "1.16.8"

group :development, :test do
  gem "decidim-dev", DECIDIM_VERSION

  # rubocop & rubocop-rspec are set to the following versions because of a change where FactoryBot/CreateList
  # must be a boolean instead of contextual. These version locks can be removed when this problem is handled
  # through decidim-dev.
  gem "rubocop", "~>1.28"
  gem "rubocop-faker"
  gem "rubocop-rspec", "2.20"

  # Fix issue with simplecov-cobertura
  # See: https://github.com/jessebs/simplecov-cobertura/pull/44
  gem "rexml", "3.4.1"
end

group :development do
  # Lock faker to older version to avoid seed errors from Decidim
  # (Faker::Twitter no longer exists in newer versions)
  gem "faker", "3.2"

  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.1"
end
