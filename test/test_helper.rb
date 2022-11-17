# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

require 'webmock/minitest'

module ActiveSupport
  class TestCase
    include FactoryBot::Syntax::Methods

    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...

    # Pundit permission assertions
    def assert_permit(policy, user, record, action)
      msg = "User #{user.inspect} should be permitted to #{action} #{record}, but isn't permitted"

      assert permit(policy, user, record, action), msg
    end

    def assert_not_permit(policy, user, record, action)
      msg = "User #{user.inspect} should NOT be permitted to #{action} #{record}, but is permitted"

      assert_not permit(policy, user, record, action), msg
    end

    def permit(policy, user, record, action)
      policy.new(user, record).public_send("#{action}?")
    end
  end
end

# Disable external requests
# https://github.com/titusfortner/webdrivers/wiki/Using-with-VCR-or-WebMock
driver_urls = (ObjectSpace.each_object(Webdrivers::Common.singleton_class).to_a - [Webdrivers::Common])
  .map(&:base_url)
WebMock.disable_net_connect!(allow_localhost: true, allow: driver_urls)

# Use OmniAuth in test mode
OmniAuth.config.test_mode = true
