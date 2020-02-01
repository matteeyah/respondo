# frozen_string_literal: true

require_relative 'boot'

# Based on https://github.com/rails/rails/blob/v6.0.0/railties/lib/rails/all.rb
# Only load the railties we need instead of loading everything
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'active_job/railtie'
require 'sprockets/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Respondo
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Load ruby files in lib/
    config.autoload_paths << Rails.root.join('lib')
  end
end
