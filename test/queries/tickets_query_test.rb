# frozen_string_literal: true

require 'test_helper'

class TicketsQueryTest < ActiveSupport::TestCase
  test 'filters by status' do
    query = TicketsQuery.new(Ticket.all, status: 'solved')
    tickets(:internal_disqus).update!(status: 'solved')

    assert_equal [tickets(:internal_disqus)], query.call
  end

  test 'defaults to open status by default' do
    query = TicketsQuery.new(Ticket.all, status: '')
    tickets(:internal_disqus).update!(status: 'solved')

    assert_equal [tickets(:internal_twitter), tickets(:external)], query.call
  end

  test 'filters by author' do
    query = TicketsQuery.new(Ticket.all, query: 'robert_is_cool')

    assert_equal [tickets(:internal_disqus)], query.call
  end

  test 'filters by content' do
    query = TicketsQuery.new(Ticket.all, query: 'Internal twitter ticket content.')

    assert_equal [tickets(:internal_twitter)], query.call
  end
end
