# frozen_string_literal: true

Flipper.configure do |config|
  config.default do
    # Persist feature flag settings in the database
    adapter = Flipper::Adapters::ActiveRecord.new

    # Default flipper instance
    Flipper.new(adapter)
  end
end

Rails.application.configure do
  config.flipper.preload = false

  # config.flipper.memoize = ->(request) { !request.path.start_with?('/assets') }
end
