# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Github
gem 'europeana-i18n', github: 'europeana/europeana-i18n-ruby', branch: 'develop'
gem 'europeana-styleguide', github: 'europeana/europeana-styleguide-ruby', branch: 'develop'

# rubygems.org
gem 'aasm'
gem 'cancancan'
gem 'cancancan-mongoid'
gem 'carrierwave-mongoid'
gem 'colorize'
gem 'devise'
gem 'fog-aws'
gem 'i18n_data'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'json-ld'
gem 'kaminari-mongoid'
gem 'mini_magick'
gem 'mongoid', '~> 6.4'
gem 'mongoid-uuid'
gem 'mustache', '1.0.3'
gem 'nested_form_fields'
gem 'oai'
gem 'puma'
gem 'rails', '5.1.6.1'
gem 'rdf'
gem 'rdf-rdfxml'
gem 'rdf-turtle'
gem 'rdf-vocab'
gem 'recaptcha', require: 'recaptcha/rails'
gem 'redis-namespace'
gem 'redis-rails'
gem 'sass-rails'
gem 'sidekiq'
gem 'sidekiq-scheduler'
gem 'simple_form'
gem 'stache'

group :development, :production do
  gem 'newrelic_rpm'
end

group :development, :test do
  gem 'binding_of_caller'
  gem 'byebug', platforms: %i(mri mingw x64_mingw)
  gem 'dotenv-rails'
  gem 'rubocop', '~> 0.53', require: false
end

group :production do
  gem 'europeana-logging'
  gem 'rails_serve_static_assets'
  gem 'uglifier'
end

group :development do
  gem 'better_errors'
  gem 'brakeman'
  gem 'foreman'
  gem 'listen'
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'web-console'
  gem 'yard'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'forgery'
  gem 'geckodriver-helper'
  gem 'mongoid-rspec'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'rspec-sidekiq'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'webmock'
end
