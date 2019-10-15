# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

# Core
gem 'bootsnap', '>= 1.4.2', require: false # Reduces boot times through caching; required in config/boot.rb
gem 'puma', '~> 3.11' # Use Puma as the application server
gem 'rails', '~> 6.0.0'
gem 'turbolinks', '~> 5' # Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'webpacker', '~> 4.0' # Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker

# Not used
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Omniauth
gem 'omniauth-google-oauth2', '~> 0.6.0'
gem 'omniauth-twitter', '~> 1.4.0'
# Other
gem 'attr_encrypted', '~> 3.1.0' # encrypted attributes
gem 'bootstrap', '~> 4.3.1' # Twitter bootstrap styling
gem 'haml-rails', '~> 2.0' # HAML markup processing
gem 'hashie', '~> 3.6.0' # Hash utilities
gem 'pagy', '~> 3.5' # Pagination
gem 'sass-rails', '~> 5' # SCSS CSS pre-processor
gem 'twitter', '~> 6.2.0' # Twitter client

group :development, :test do
  # Linters
  ## Ruby linter
  gem 'rubocop', '~> 0.74.0', require: false
  gem 'rubocop-performance', '~> 1.4.1', require: false
  gem 'rubocop-rails', '~> 2.3.2', require: false
  gem 'rubocop-rspec', '~> 1.35.0', require: false
  ## Haml linter
  gem 'haml_lint', '~> 0.33.0', require: false
  # Other
  gem 'bullet', '~> 6.0.2' # N+1 monitoring
  gem 'factory_bot_rails', '~> 5.0.2' # Use factory_bot
  gem 'faker', '~> 2.2.2' # Sample data
  gem 'pry-byebug', '~> 3.7.0' # pry debugging
  gem 'rspec-rails', '4.0.0.beta2' # rspec testing framework
  gem 'sqlite3', '~> 1.4' # AR database adapter
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
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
  gem 'mini_racer', '~> 0.2.6' # JS runtime for execjs
  gem 'shoulda-matchers', '~> 4.1.2' # One-liner matchers
  gem 'simplecov', '~> 0.16.1', require: false # Coverage
end

group :production do
  gem 'pg', '~> 1.1.4' # AR database adapter
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
