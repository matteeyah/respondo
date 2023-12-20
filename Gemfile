# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

# Core
gem 'bcrypt', '~> 3.1.7' # Use Active Model has_secure_password
gem 'bootsnap', '>= 1.4.2', require: false # Reduces boot times through caching; required in config/boot.rb
gem 'importmap-rails'
gem 'puma' # Use Puma as the application server
gem 'rails', '~> 7.1.1'
gem 'stimulus-rails' # Hotwire Stimulus
gem 'turbo-rails' # Hotwire Turbo

# Not used
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'hiredis'
# gem 'redis'
# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Omniauth
gem 'omniauth-azure-activedirectory-v2'
gem 'omniauth-google-oauth2'
gem 'omniauth-linkedin-openid'
gem 'omniauth-rails_csrf_protection'
gem 'omniauth-twitter'
# Other
gem 'active_link_to' # View helper for adding active class
gem 'google-cloud-storage', require: false
gem 'hashie' # Hash utilities
gem 'json-schema' # JSON schema validation
gem 'mailgun-ruby' # Mailgun backend for ActionMailer
gem 'pagy' # Pagination
gem 'pg' # AR database adapter
gem 'propshaft' # Rails assets
gem 'ruby-openai'
gem 'solid_queue'
gem 'x' # Twitter client

group :development, :test do
  ## Ruby linter
  gem 'rubocop', require: false
  gem 'rubocop-minitest', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  ## ERB
  gem 'erb_lint', require: false
  # Other
  gem 'debug'
end

group :development do
  gem 'ruby-lsp-rails'
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Other
  gem 'webmock', '~> 3.18' # Stubs and expectations for HTTP requests
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
