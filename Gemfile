# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

# Core
gem 'bcrypt', '~> 3.1.7' # Use Active Model has_secure_password
gem 'bootsnap', '>= 1.4.2', require: false # Reduces boot times through caching; required in config/boot.rb
gem 'importmap-rails', '~> 1.1.0'
gem 'puma', '~> 5.6.4' # Use Puma as the application server
gem 'rails', '~> 7.0.3'
gem 'turbo-rails', '~> 1.1.1' # Hotwire Turbo

# Not used
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Omniauth
gem 'omniauth-disqus', '~> 1.0.1'
gem 'omniauth-google-oauth2', '~> 1.0.0'
gem 'omniauth-twitter', '~> 1.4.0'
# This prevents CSRF in Omniauth authentication requests
# It should be removed when upstream is fixed
# https://github.com/Respondo/respondo/issues/68
gem 'omniauth-rails_csrf_protection', '~> 1.0.0'
# Other
gem 'aasm', '~> 5.2.0' # state machine
gem 'active_link_to', '~> 1.0.5' # View helper for adding active class
gem 'attr_encrypted', '~> 3.1.0' # encrypted attributes
gem 'disqus_api', '~> 0.0.7' # Disqus client
gem 'flipper-active_record', '~> 0.25.0' # ActiveRecord adapter for flipper
gem 'hamlit', '~> 2.16.0' # High-Performance HAML markup processing
gem 'hashie', '~> 5.0.0' # Hash utilities
gem 'json-schema', '~> 3.0.0' # JSON schema validation
gem 'pagy', '~> 5.10.1' # Pagination
gem 'pundit', '~> 2.2.0' # OO Policy objects
gem 'sass-rails', '~> 6.0.0' # SCSS CSS pre-processor
gem 'sidekiq', '~> 6.5.0' # Background job processing
gem 'twitter', '~> 7.0.0' # Twitter client

group :development, :test do
  # Linters
  ## Ruby linter
  gem 'rubocop', '~> 1.30.1', require: false
  gem 'rubocop-performance', '~> 1.14.2', require: false
  gem 'rubocop-rails', '~> 2.14.2', require: false
  gem 'rubocop-rspec', '~> 2.11.1', require: false
  ## Haml linter
  gem 'haml_lint', '~> 0.40.0', require: false
  # Other
  gem 'factory_bot_rails', '~> 6.2.0' # Use factory_bot
  gem 'faker', '~> 2.21.0' # Sample data
  gem 'license_finder', '~> 7.0.1' # license checking
  gem 'pry-byebug', '~> 3.9.0' # pry debugging
  gem 'rspec-rails', '~> 5.1.2' # rspec testing framework
  gem 'sqlite3', '~> 1.4' # AR database adapter
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '~> 3.7.1'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Other
  gem 'dotenv-rails', '~> 2.7.5' # .env
  gem 'pry-rails', '~> 0.3.9' # pry console
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'webdrivers' # Easy installation and use of web drivers to run system tests with browsers
  # Other
  gem 'mini_racer', '~> 0.6.2' # JS runtime for execjs
  gem 'shoulda-matchers', '~> 5.1.0' # One-liner matchers
  gem 'simplecov', '~> 0.21.1', require: false # Code coverage
  gem 'webmock', '~> 3.14.0' # Stubs and expectations for HTTP requests
end

group :production do
  gem 'pg', '~> 1.3.5' # AR database adapter
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
