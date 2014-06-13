source 'https://rubygems.org'
ruby '2.1.1'

gem 'rails', '4.1.1'

gem 'pg'

gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-datatables-rails', '~> 1.12.0', git: 'git://github.com/rweng/jquery-datatables-rails.git'
gem 'uglifier', '>= 1.3.0'
gem 'sass-rails', '~> 4.0.1'
gem 'haml', '~> 4.0.4'
gem 'bootstrap-sass', '~> 3.0.2.1'

gem 'omniauth-github'
gem 'omniauth-twitter'

gem 'chartkick'
gem 'groupdate'
gem 'country_select'
gem 'redcarpet', '~> 3.0.0'
gem 'coderay', '~> 1.0'
gem 'bootstrap-multiselect-rails', github: 'itsNikolay/bootstrap-multiselect-rails', branch: 'rails4_and_update_and_fix'
gem 'active_model_serializers', '~> 0.8.1'
gem 'draper'
gem 'simple_form', '3.1.0.rc1'

gem 'zeroclipboard-rails'

group :production do
  gem 'rails_12factor'
  gem 'unicorn'
end

group :development do
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'foreman'
  gem 'launchy'
  gem 'pry'
  gem 'pry-debugger'
  gem 'pry-rails'
  gem 'quiet_assets'
  gem 'thin'
  gem 'rack-mini-profiler'
  gem 'haml-rails'
  gem "spring-commands-rspec", require: false
end

group :development, :test do
  gem 'capybara-webkit'
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
end
