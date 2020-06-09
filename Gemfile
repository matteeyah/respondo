# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.1'

# Core
gem 'bcrypt', '~> 3.1.7' # Use Active Model has_secure_password
gem 'bootsnap', '>= 1.4.2', require: false # Reduces boot times through caching; required in config/boot.rb
gem 'puma', '~> 4.3.5' # Use Puma as the application server
gem 'rails', '~> 6.0.3.1'
gem 'turbolinks', '~> 5' # Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'webpacker', '~> 5.1.1' # Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker

# Not used
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Omniauth
gem 'omniauth-disqus', '~> 1.0.1'
gem 'omniauth-google-oauth2', '~> 0.8.0'
gem 'omniauth-twitter', '~> 1.4.0'
# Other
gem 'aasm', '~> 5.0.6' # state machine
gem 'active_link_to', '~> 1.0.5' # View helper for adding active class
gem 'attr_encrypted', '~> 3.1.0' # encrypted attributes
gem 'disqus_api', '~> 0.0.7' # Disqus client
gem 'flipper', '~> 0.17.2' # Feature flags
gem 'flipper-active_record', '~> 0.17.2' # ActiveRecord adapter for flipper
gem 'hamlit', '~> 2.11.0' # High-Performance HAML markup processing
gem 'hashie', '~> 4.1.0' # Hash utilities
gem 'json-schema', '~> 2.8.1' # JSON schema validation
gem 'pagy', '~> 3.5' # Pagination
gem 'pundit', '~> 2.1.0' # OO Policy objects
gem 'sass-rails', '~> 6.0.0' # SCSS CSS pre-processor
gem 'sidekiq', '~> 6.0.7' # Background job processing
gem 'twitter', '~> 7.0.0' # Twitter client

group :development, :test do
  # Linters
  ## Ruby linter
  gem 'rubocop', '~> 0.85.0', require: false
  gem 'rubocop-performance', '~> 1.6.1', require: false
  gem 'rubocop-rails', '~> 2.5.0', require: false
  gem 'rubocop-rspec', '~> 1.39.0', require: false
  ## Haml linter
  gem 'haml_lint', '~> 0.35.0', require: false
  # Other
  gem 'bullet', '~> 6.1.0' # N+1 monitoring
  gem 'factory_bot_rails', '~> 5.2.0' # Use factory_bot
  gem 'faker', '~> 2.12.0' # Sample data
  gem 'html-proofer', '~> 3.15.0' # Runtime HTML proofer
  gem 'license_finder', '~> 6.5.0' # license checking
  gem 'pry-byebug', '~> 3.9.0' # pry debugging
  gem 'rspec-rails', '4.0.1' # rspec testing framework
  gem 'sqlite3', '~> 1.4' # AR database adapter
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '~> 3.2.1'
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
  gem 'shoulda-matchers', '~> 4.3.0' # One-liner matchers
  gem 'simplecov', '~> 0.18.5', require: false # Code coverage
  gem 'webmock', '~> 3.8.3' # Stubs and expectations for HTTP requests
end

group :production do
  gem 'pg', '~> 1.2.3' # AR database adapter
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
