# frozen_string_literal: true

source 'https://rubygems.org'

# https://andycroll.com/ruby/read-ruby-version-in-your-gemfile/
ruby File.read(".ruby-version").strip

gem 'puma'
gem 'rails', '~> 8.0.2'
gem 'mimemagic'
gem 'mime-types-data'
gem 'mime-types'
gem 'rexml'
gem 'matrix'
gem 'honeybadger', '~> 5.27'

gem 'csv'

gem 'pg'

gem 'bootstrap-sass', '~> 3.4.1'
gem 'haml'
gem 'jbuilder'
gem 'jquery-datatables-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'rails-assets-momentjs', source: 'https://rails-assets.org'
gem 'sassc-rails'
gem 'selectize-rails'
gem 'uglifier', '>= 1.3.0'
gem 'underscore-rails'

gem 'devise', '~> 4.9'
gem 'omniauth-github'
gem 'omniauth-twitter'
gem "omniauth-rails_csrf_protection", "~> 1.0"

gem 'actionview-encoded_mail_to'
gem 'active_model_serializers', '~> 0.10.15'
gem 'bootsnap', '~> 1.18', require: false
gem 'bootstrap-multiselect-rails', '~> 0.9.9'
gem 'chartkick'
gem 'coderay', '~> 1.0'
gem 'country_select', '~> 10.0'
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
gem 'react-rails'
gem 'shakapacker', '~> 8.2'

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
  gem 'database_cleaner', '~> 2.1'
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'growl'
  gem 'guard'
  gem 'guard-livereload', '~> 2.1'
  gem 'guard-rspec'
  gem 'rails-controller-testing'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'timecop'
end
