# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.1'

# Core
gem 'bcrypt', '~> 3.1.7' # Use Active Model has_secure_password
gem 'bootsnap', '>= 1.4.2', require: false # Reduces boot times through caching; required in config/boot.rb
gem 'importmap-rails'
gem 'puma' # Use Puma as the application server
gem 'rails', '~> 7.0.4'
gem 'stimulus-rails' # Hotwire Stimulus
gem 'turbo-rails' # Hotwire Turbo

# Not used
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
gem 'hiredis'
gem 'redis'
# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Omniauth
gem 'omniauth-activedirectory'
gem 'omniauth-disqus'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'
gem 'omniauth-twitter'
# Other
gem 'active_link_to' # View helper for adding active class
gem 'acts-as-taggable-on' # Tags mechanism
gem 'dartsass-rails' # SASS processor for Rails
gem 'disqus_api' # Disqus client
gem 'flipper' # Feature flags
gem 'flipper-active_record' # ActiveRecord adapter for flipper
gem 'hashie' # Hash utilities
gem 'json-schema' # JSON schema validation
gem 'pagy' # Pagination
gem 'pg' # AR database adapter
gem 'propshaft' # Rails assets
gem 'rails-assets-bootstrap', source: 'https://rails-assets.org' # Bootstrap
gem 'resque' # Background job processing
gem 'twitter' # Twitter client

group :development, :test do
  # Linters
  gem 'license_finder' # license checking
  gem 'mdl', require: false
  ## Ruby linter
  gem 'rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-md', require: false
  gem 'rubocop-minitest', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  ## ERB
  gem 'erb_lint', require: false
  # Other
  gem 'debug', '1.7.0'
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
  gem 'webmock', '~> 3.18' # Stubs and expectations for HTTP requests
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
