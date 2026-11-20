# frozen_string_literal: true

source 'https://rubygems.org'

ruby file: '.ruby-version'

require_relative 'config/website_flag'

gem 'puma'
gem 'rails', '~> 8.1.4'
gem 'turbo-rails'
gem 'solid_queue'
gem 'mission_control-jobs'

gem 'propshaft'
gem 'jsbundling-rails'
gem 'cssbundling-rails'

gem 'honeybadger', '~> 6.10'

gem 'csv'

gem 'pg'

gem 'haml-rails'

gem 'omniauth-github'
gem 'omniauth-twitter'
gem "omniauth-rails_csrf_protection", "~> 2.0"

gem 'stateful_enum'

gem 'actionview-encoded_mail_to'
gem 'active_model_serializers', '~> 0.10.16'
gem 'bootsnap', '~> 1.26', require: false
# The beta website feature. Its gems (aws-sdk-s3, fastly, image_processing) are
# resolved into Gemfile.lock either way but only installed, and put on the load
# path, when ENABLE_WEBSITE is set in the environment at `bundle install` and
# boot time (see config/website_flag.rb and engines/cfp_website/README.md).
install_if -> { CfpApp.website_enabled? } do
  gem 'cfp_website', path: 'engines/cfp_website', require: false
end
gem 'chartkick'
gem 'draper', '~> 4.0'
gem 'groupdate'
gem 'pundit'
gem 'redcarpet', '~> 3.6'
gem 'simple_form'

gem 'diffy'
gem 'paper_trail'

gem 'sendgrid-ruby'

group :production do
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
  gem 'simplecov', require: false
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'debug'
  gem 'faker'
  gem 'letter_opener_web'
end

gem "bcrypt", "~> 3.1"
