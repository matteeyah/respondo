# frozen_string_literal: true

require 'test_helper'

class InboundMailboxTest < ActionMailbox::TestCase
  include ActionMailer::TestHelper

  test 'does not create tickets when organization is missing' do
    assert_no_difference -> { Ticket.count } do
      receive_inbound_email_from_mail \
        to: '"respondo" <inbound+999@mail.respondohub.com>',
        from: '"someone" <someone@example.com>',
        subject: 'Hello world!',
        body: 'Hello?'
    end
  end

  test 'bounces mail when organization is missing' do
    assert_enqueued_emails(1) do
      receive_inbound_email_from_mail \
        to: '"respondo" <inbound+999@mail.respondohub.com>',
        from: '"someone" <someone@example.com>',
        subject: 'Hello world!',
        body: 'Hello?'
    end
  end

  test 'creates ticket when organization is right' do
    assert_difference -> { Ticket.count }, 1 do
      receive_inbound_email_from_mail \
        to: "\"respondo\" <inbound+#{organizations(:respondo).id}@mail.respondohub.com>",
        from: '"someone" <someone@example.com>',
        subject: 'Hello world!',
        body: 'Hello?',
        external_link: 'https://external.com/james_is_cool'
    end
  end
end
