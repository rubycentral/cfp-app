source 'https://rubygems.org'
ruby '2.3.1'

gem 'rails', '4.2.5'
gem 'puma', '~> 2.13'

gem 'pg'

gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-datatables-rails', github: "rweng/jquery-datatables-rails"
gem 'uglifier', '>= 1.3.0'
gem 'sass-rails', '~> 5.0.4'
gem 'haml', '~> 4.0.4'
gem 'bootstrap-sass', '~> 3.3.6'
gem 'rails-assets-momentjs', source: 'https://rails-assets.org'

gem 'devise', '~> 4.1.1'
gem 'omniauth-github'
gem 'omniauth-twitter'

gem 'chartkick'
gem 'groupdate'
gem 'country_select', '~> 1.3.1'
gem 'redcarpet', '~> 3.0.0'
gem 'coderay', '~> 1.0'
gem 'bootstrap-multiselect-rails', '~> 0.9.9'
gem 'active_model_serializers', '~> 0.8.1'
gem 'draper'
gem 'simple_form', '3.1.1'
gem 'zeroclipboard-rails'
gem 'responders', '~> 2.0'
gem 'pundit'
gem 'faker'
gem 'actionview-encoded_mail_to'

group :production do
  gem 'rails_12factor'
  gem 'rack-timeout', '~> 0.2.4'
end

group :development do
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'foreman'
  gem 'launchy'
  gem 'quiet_assets'
  gem 'rack-mini-profiler'
  gem 'haml-rails'
  gem 'spring-commands-rspec', require: false
  gem 'web-console', '~> 2.0'
end

group :development, :test do
  gem 'capybara', '>= 2.2'
  gem 'capybara-webkit', '~> 1.6.0' # Local QT install req'd (`brew install qt`)
  gem 'database_cleaner'
  gem 'dotenv-rails'
  gem 'factory_girl_rails'
  gem 'growl'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-livereload', '~> 2.1.1'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'timecop'
  gem 'spring'
  gem 'pry-rails'
  gem 'pry-rescue'
  gem 'pry-remote'
end
