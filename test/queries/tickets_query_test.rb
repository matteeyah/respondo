# frozen_string_literal: true

require 'test_helper'

class TicketsQueryTest < ActiveSupport::TestCase
  test 'filters by status' do
    query = TicketsQuery.new(Ticket.all, status: 'solved')
    tickets(:external).update!(status: 'solved')

    assert_equal [tickets(:external)], query.call
  end

  test 'defaults to open status by default' do
    query = TicketsQuery.new(Ticket.all, status: '')
    tickets(:external).update!(status: 'solved')

    assert_equal [tickets(:x), tickets(:email)], query.call
  end

  test 'filters by assignee' do
    query = TicketsQuery.new(Ticket.all, assignee: users(:john).id)

    assert_equal [tickets(:x)], query.call
  end

  test 'filters by tag' do
    tickets(:x).tag_list.add('hello')
    tickets(:x).save!
    query = TicketsQuery.new(Ticket.all, tag: 'hello')

    assert_equal [tickets(:x)], query.call
  end

  test 'filters by author' do
    query = TicketsQuery.new(Ticket.all, author: 'matt_is_cool')

    assert_equal [tickets(:external)], query.call
  end

  test 'filters by content' do
    query = TicketsQuery.new(Ticket.all, content: 'Internal x ticket content.')

    assert_equal [tickets(:x)], query.call
  end
end
