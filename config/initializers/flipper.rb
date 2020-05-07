# frozen_string_literal: true

Flipper.configure do |config|
  config.default do
    # Persist feature flag settings in the database
    adapter = Flipper::Adapters::ActiveRecord.new

    # Default flipper instance
    Flipper.new(adapter)
  end
end
