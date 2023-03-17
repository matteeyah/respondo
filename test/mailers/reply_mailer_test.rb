# frozen_string_literal: true

require 'test_helper'

class ReplyMailerTest < ActionMailer::TestCase
  test 'respond' do
    email = ReplyMailer.respond('hello@example.com', nil, 'Hello World', 1, 'Hello from a test')

    assert_emails 1 do
      email.deliver_now
    end
  end
end
