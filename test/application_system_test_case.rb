# frozen_string_literal: true

require 'test_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by(:selenium, using: :headless_chrome, screen_size: [1920, 1080]) do |driver_options|
    # headless chrome can't run in Docker with sandboxing
    driver_options.add_argument('no-sandbox')
  end
end
