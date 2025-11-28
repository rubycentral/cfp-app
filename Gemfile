# frozen_string_literal: true

source 'https://rubygems.org'

ruby file: '.ruby-version'

gem 'puma'
gem 'rails', '~> 8.1.1'
gem 'mimemagic'
gem 'mime-types-data'
gem 'mime-types'
gem 'rexml'
gem 'matrix'

gem 'sprockets-rails'
gem 'shakapacker', '~> 6.6'

gem 'honeybadger', '~> 6.1'

gem 'csv'

gem 'pg'

gem 'haml'
gem 'jquery-rails'
gem 'uglifier', '>= 1.3.0'

gem 'devise', '~> 4.9'
gem 'omniauth-github'
gem 'omniauth-twitter'
gem "omniauth-rails_csrf_protection", "~> 2.0"

gem 'actionview-encoded_mail_to'
gem 'active_model_serializers', '~> 0.10.15'
gem 'bootsnap', '~> 1.19', require: false
gem 'chartkick'
gem 'coderay', '~> 1.0'
gem 'country_select', '~> 11.0'
gem 'draper', '~> 4.0'
gem 'faker'
gem 'fastly'
gem 'groupdate'
gem 'nokogiri'
gem 'pundit'
gem 'redcarpet', '~> 3.6'
gem 'simple_form'
gem 'tinymce-rails'
gem 'image_processing', '~> 1.14'

gem 'sidekiq'

gem 'diffy'
gem 'paper_trail'

gem 'sendgrid-ruby'

group :production do
  gem 'aws-sdk-s3'
  gem 'rack-timeout', '~> 0.7'
end

group :development do
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'foreman'
  gem 'haml-rails'
  gem 'launchy'
  gem 'rack-mini-profiler'
  gem 'web-console'
end

group :development, :test do
  gem 'capybara', '~> 3.37'
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'guard'
  gem 'guard-livereload', '~> 2.1'
  gem 'guard-rspec'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
end
