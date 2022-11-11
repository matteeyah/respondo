# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

# Core
gem 'bcrypt', '~> 3.1.7' # Use Active Model has_secure_password
gem 'bootsnap', '>= 1.4.2', require: false # Reduces boot times through caching; required in config/boot.rb
gem 'importmap-rails', '~> 1.1.0'
gem 'puma', '~> 6.0.0' # Use Puma as the application server
gem 'rails', '~> 7.0.3'
gem 'stimulus-rails', '~> 1.1.0' # Hotwire Stimulus
gem 'turbo-rails', '~> 1.3.2' # Hotwire Turbo

# Not used
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 5.0.4'
# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Omniauth
gem 'omniauth-activedirectory', '~> 1.0.1'
gem 'omniauth-disqus', '~> 1.0.1'
gem 'omniauth-google-oauth2', '~> 1.0.1'
gem 'omniauth-rails_csrf_protection', '~> 1.0.0'
gem 'omniauth-twitter', '~> 1.4.0'
# Other
gem 'active_link_to', '~> 1.0.5' # View helper for adding active class
gem 'acts-as-taggable-on' # Tags mechanism
gem 'dartsass-rails', '~> 0.4.0' # SASS processor for Rails
gem 'disqus_api', '~> 0.0.7' # Disqus client
gem 'flipper', '~> 0.25.0' # Feature flags
gem 'flipper-active_record', '~> 0.25.0' # ActiveRecord adapter for flipper
gem 'haml', '~> 6.0.10' # HAML markup processing
gem 'hashie', '~> 5.0.0' # Hash utilities
gem 'json-schema', '~> 3.0.0' # JSON schema validation
gem 'pagy', '~> 5.10.1' # Pagination
gem 'propshaft', '~> 0.6.4' # Rails assets
gem 'pundit', '~> 2.2.0' # OO Policy objects
gem 'resque', '~> 2.4.0' # Background job processing
gem 'twitter', '~> 7.0.0' # Twitter client

group :development, :test do
  # Linters
  gem 'mdl', '~> 0.12.0', require: false
  ## Ruby linter
  gem 'rubocop', '~> 1.38.0', require: false
  gem 'rubocop-md', '~> 1.1.0', require: false
  gem 'rubocop-minitest', '~> 0.23.2', require: false
  gem 'rubocop-performance', '~> 1.15.0', require: false
  gem 'rubocop-rails', '~> 2.17.2', require: false
  gem 'rubocop-rspec', '~> 2.15.0', require: false
  ## Haml linter
  gem 'haml_lint', '~> 0.42.0', require: false
  # Other
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails', '~> 6.2.0' # Use factory_bot
  gem 'faker', '~> 3.0.0' # Sample data
  gem 'license_finder', '~> 7.0.1' # license checking
  gem 'rspec-rails', '~> 6.0.1' # rspec testing framework
  gem 'sqlite3', '~> 1.4' # AR database adapter
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'webdrivers' # Easy installation and use of web drivers to run system tests with browsers
  # Other
  gem 'shoulda-matchers', '~> 5.2.0' # One-liner matchers
  gem 'simplecov', '~> 0.21.1', require: false # Code coverage
  gem 'webmock', '~> 3.18.1' # Stubs and expectations for HTTP requests
end

group :production do
  gem 'pg', '~> 1.4.4' # AR database adapter
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
