# frozen_string_literal: true

require 'test_helper'

class InternalTicketTest < ActiveSupport::TestCase
  test '#provider returns source provider' do
    ticket = internal_tickets(:twitter)

    assert_equal ticket.source.provider, ticket.provider
  end
end
