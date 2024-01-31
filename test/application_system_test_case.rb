# frozen_string_literal: true

require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by(:selenium, using: :headless_chrome, screen_size: [ 1920, 1080 ]) do |driver_options|
    if ENV["CI"] || ENV["CI_SERVER"]
      # Disable /dev/shm use in CI.
      driver_options.add_argument("disable-dev-shm-usage")
      # Headless chrome can't run in Docker with sandboxing.
      driver_options.add_argument("no-sandbox")
    end
  end

  private

  def find_icon_link(icon)
    find(:xpath, %(.//i[contains(@class, "bi-#{icon}")]/..))
  end
end
