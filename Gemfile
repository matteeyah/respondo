# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.4'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.0'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 4.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# HAML markup processing
gem 'haml-rails', '~> 2.0'

# Twitter bootstrap styling
gem 'bootstrap', '~> 4.3.1'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

# Omniauth
gem 'omniauth-google-oauth2', '~> 0.6.0'
gem 'omniauth-twitter', '~> 1.4.0'

# Twitter
gem 'twitter', '~> 6.2.0'

# encrypted attributes
gem 'attr_encrypted', '~> 3.1.0'

# Pagination
gem 'pagy', '~> 3.5'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  # Use rspec for testing
  gem 'rspec-rails', '4.0.0.beta2'
  # Use factory_bot
  gem 'factory_bot_rails', '~> 5.0.2'
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3', '~> 1.4'
  # Ruby linter
  gem 'rubocop', '~> 0.74.0', require: false
  gem 'rubocop-performance', '~> 1.4.1', require: false
  gem 'rubocop-rails', '~> 2.3.2', require: false
  gem 'rubocop-rspec', '~> 1.35.0', require: false
  # Haml linter
  gem 'haml_lint', '~> 0.33.0', require: false
  # Sample data
  gem 'faker', '~> 2.2.2'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # .env
  gem 'dotenv-rails', '~> 2.7.5'
  # pry
  gem 'pry-rails', '~> 0.3.9'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
  # JS runtime for execjs
  gem 'mini_racer', '~> 0.2.6'
  # One-liner matchers
  gem 'shoulda-matchers', '~> 4.1.2'
  # pry
  gem 'pry-byebug', '~> 3.7.0'
  # Coverage
  gem 'simplecov', '~> 0.16.1', require: false
end

group :production do
  # Use pg as the database for Active Record
  gem 'pg', '~> 1.1.4'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
