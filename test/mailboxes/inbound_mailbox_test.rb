# frozen_string_literal: true

require 'test_helper'

class InboundMailboxTest < ActionMailbox::TestCase
  test "receive mail" do
    receive_inbound_email_from_mail \
      to: '"someone" <inbound+4@mail.respondohub.com>',
      from: '"else" <inbound+4@mail.respondohub.com>',
      subject: "Hello world!",
      body: "Hello?"
  end
end
