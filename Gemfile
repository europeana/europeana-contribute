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
gem 'carrierwave-mongoid'
gem 'colorize'
gem 'fog-aws'
gem 'iso639'
gem 'kaminari-mongoid'
gem 'mongoid'
gem 'mustache', '1.0.3'
gem 'oai'
gem 'rails'
gem 'rails_admin'
gem 'rdf'
gem 'rdf-rdfxml'
gem 'rdf-vocab'
gem 'sass-rails'
gem 'simple_form'
gem 'stache'

group :development, :production do
  gem 'newrelic_rpm'
  gem 'puma'
end

group :development, :test do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'byebug', platforms: %i(mri mingw x64_mingw)
  gem 'dotenv-rails'
  gem 'rubocop', require: false
end

group :production do
  gem 'europeana-logging'
  gem 'rails_serve_static_assets'
  gem 'uglifier'
end

group :development do
  gem 'foreman'
  gem 'listen'
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'web-console'
end

group :test do
  gem 'coveralls', require: false
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'forgery'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'shoulda-matchers', require: false
  gem 'simplecov', require: false
  gem 'webmock'
end
