# frozen_string_literal: true

source 'https://rubygems.org'

# https://andycroll.com/ruby/read-ruby-version-in-your-gemfile/
ruby File.read(".ruby-version").strip

gem 'puma'
gem 'rails', '~> 6.1.6'
gem 'mimemagic', github: 'mimemagicrb/mimemagic', ref: '01f92d86d15d85cfd0f20dabd025dcbd36a8a60f'
gem 'mime-types-data'
gem 'mime-types'
gem 'rexml'
gem 'matrix'
gem 'honeybadger', '~> 4.0'

# Required until Rails 7 - https://github.com/mikel/mail/pull/1472#issuecomment-1165161541
gem 'net-smtp', require: false
gem 'net-imap', require: false
gem 'net-pop', require: false

gem 'pg'

gem 'bootstrap-sass', '~> 3.4.1'
gem 'haml', '~> 5.0'
gem 'jbuilder'
gem 'jquery-datatables-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'rails-assets-momentjs', source: 'https://rails-assets.org'
gem 'sassc-rails'
gem 'selectize-rails'
gem 'uglifier', '>= 1.3.0'
gem 'underscore-rails'

gem 'devise', '~> 4.8'
gem 'omniauth-github'
gem 'omniauth-twitter'
gem "omniauth-rails_csrf_protection", "~> 1.0"

gem 'actionview-encoded_mail_to'
gem 'active_model_serializers', '~> 0.10.0'
gem 'bootsnap', '~> 1.13', require: false
gem 'bootstrap-multiselect-rails', '~> 0.9.9'
gem 'chartkick'
gem 'coderay', '~> 1.0'
gem 'country_select', '~> 8.0'
gem 'draper', '~> 4.0'
gem 'faker'
gem 'fastly'
gem 'groupdate'
gem 'nokogiri'
gem 'pundit'
gem 'redcarpet', '~> 3.5'
gem 'simple_form'
gem 'tinymce-rails'
gem 'image_processing', '~> 1.2'
gem 'react-rails'
gem 'webpacker'

gem 'sidekiq'

gem 'paper_trail'

gem 'sendgrid-ruby'

group :production do
  gem 'aws-sdk-s3'
  gem 'rack-timeout', '~> 0.6'
end

group :development do
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'foreman'
  gem 'haml-rails'
  gem 'html2haml', '~> 2.2'
  gem 'launchy'
  gem 'rack-mini-profiler'
  gem 'spring-commands-rspec', require: false
  gem 'web-console'
end

group :development, :test do
  gem 'amazing_print', require: false
  gem 'capybara', '~> 3.37'
  gem 'database_cleaner', '~> 2.0'
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'growl'
  gem 'guard'
  gem 'guard-livereload', '~> 2.1'
  gem 'guard-rspec'
  gem 'pry-rails'
  gem 'pry-remote'
  gem 'pry-rescue'
  gem 'rails-controller-testing'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'spring'
  gem 'timecop'
  gem 'webdrivers', '~> 5.2'
end
