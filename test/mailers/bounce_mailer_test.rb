# frozen_string_literal: true

require 'test_helper'

class BounceMailerTest < ActionMailer::TestCase
  test 'no_organization' do
    email = BounceMailer.no_organization(Mail.new, Author.new(username: 'hello@example.com'))

    assert_emails 1 do
      email.deliver_now
    end
  end
end
