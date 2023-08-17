# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

require 'webmock/minitest'

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

# Disable external requests
WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: ['https://googlechromelabs.github.io', 'https://edgedl.me.gvt1.com']
)

# Use OmniAuth in test mode
OmniAuth.config.test_mode = true
