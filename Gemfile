# frozen_string_literal: true

source 'https://rubygems.org'

ruby file: '.ruby-version'

gem 'puma'
gem 'rails', '~> 8.1.1'
gem 'turbo-rails'
gem 'solid_queue'

gem 'rexml'

gem 'propshaft'
gem 'jsbundling-rails'
gem 'cssbundling-rails'

gem 'honeybadger', '~> 6.2'

gem 'csv'

gem 'pg'

gem 'haml-rails'

gem 'devise', '~> 4.9'
gem 'omniauth-github'
gem 'omniauth-twitter'
gem "omniauth-rails_csrf_protection", "~> 2.0"

gem 'stateful_enum'

gem 'actionview-encoded_mail_to'
gem 'active_model_serializers', '~> 0.10.16'
gem 'bootsnap', '~> 1.20', require: false
gem 'chartkick'
gem 'draper', '~> 4.0'
gem 'fastly'
gem 'groupdate'
gem 'nokogiri'
gem 'pundit'
gem 'redcarpet', '~> 3.6'
gem 'simple_form'
gem 'image_processing', '~> 1.14'

gem 'diffy'
gem 'paper_trail'

gem 'sendgrid-ruby'

group :production do
  gem 'aws-sdk-s3'
  gem 'rack-timeout', '~> 0.7'
end

group :development do
  gem 'annotate'
  gem 'foreman'
  gem 'launchy'
  gem 'rack-mini-profiler'
end

group :test do
  gem 'capybara', '~> 3.37'
  gem 'matrix'
  gem 'selenium-webdriver'
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'debug'
  gem 'faker'
end

gem "bcrypt", "~> 3.1"
