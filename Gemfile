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
gem "decidim-locations", github: "mainio/decidim-module-locations", branch: "develop"

gem "bootsnap", "~> 1.4"
gem "puma", ">= 5.0.0"
gem "uglifier", "~> 4.1"

group :development, :test do
  gem "decidim-dev", DECIDIM_VERSION
  gem "rubocop-faker"
  gem "rubocop-performance", "~> 1.15.0" # ?
end

group :development do
  gem "faker", "~> 2.14"
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.1"
end
