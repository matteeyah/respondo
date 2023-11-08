# frozen_string_literal: true

require 'test_helper'

class TicketsQueryTest < ActiveSupport::TestCase
  test 'filters by status' do
    query = TicketsQuery.new(Ticket.all, status: 'solved')
    tickets(:x).update!(status: 'solved')

    assert_equal [tickets(:x)], query.call
  end

  test 'defaults to open status by default' do
    query = TicketsQuery.new(Ticket.all, status: '')
    tickets(:linkedin).update!(status: 'solved')

    assert_equal [tickets(:x)], query.call
  end

  test 'filters by assignee' do
    query = TicketsQuery.new(Ticket.all, assignee: users(:john).id)

    assert_equal [tickets(:x)], query.call
  end

  test 'filters by tag' do
    tickets(:x).tags << Tag.create!(name: 'hello')
    query = TicketsQuery.new(Ticket.all, tag: 'hello')

    assert_equal [tickets(:x)], query.call
  end

  test 'filters by author' do
    query = TicketsQuery.new(Ticket.all, author: 'james_is_cool')

    assert_equal [tickets(:x)], query.call
  end

  test 'filters by content' do
    query = TicketsQuery.new(Ticket.all, content: 'X ticket content.')

    assert_equal [tickets(:x)], query.call
  end
end
