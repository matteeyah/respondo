# frozen_string_literal: true

require 'test_helper'

class EmailTicketTest < ActiveSupport::TestCase
  test 'validates presence of reply_to' do
    ticket = email_tickets(:default)
    ticket.reply_to = nil

    assert_not ticket.valid?
  end

  test 'validates format of reply_to' do
    ticket = email_tickets(:default)
    ticket.reply_to = 'helloworld'

    assert_not ticket.valid?
  end
end
