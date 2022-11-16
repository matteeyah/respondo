# frozen_string_literal: true

require 'test_helper'

class InternalTicketTest < ActiveSupport::TestCase
  test 'validates presence of response_url' do
    ticket = external_tickets(:default)
    ticket.response_url = nil

    assert_predicate ticket, :invalid?
  end

  test '#provider returns custom provider when it is set' do
    ticket = external_tickets(:default)
    ticket.custom_provider = 'hacker_news'

    assert_equal 'hacker_news', ticket.provider
  end

  test '#provider returns external when no custom provider is set' do
    assert_equal 'external', external_tickets(:default).provider
  end
end
