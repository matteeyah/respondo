# frozen_string_literal: true

require 'test_helper'

class EmailTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test '#reply sends an email' do
    client = Clients::Email.new('hello@example.com', 'Hello', 1)

    assert_emails(1) do
      client.reply('response', 'external_uid')
    end
  end

  test '#delete returns true' do
    client = Clients::Email.new('hello@example.com', 'Hello', 1)

    assert(client.delete('external_uid'))
  end

  test '#permalink returns the app root' do
    client = Clients::Email.new('hello@example.com', 'Hello', 1)

    assert_equal 'https://app.respondohub.com/tickets', client.permalink('external_uid')
  end
end
