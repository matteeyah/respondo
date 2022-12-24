# frozen_string_literal: true

require 'test_helper'

class TicketsQueryTest < ActiveSupport::TestCase
  test 'filters by status' do
    query = TicketsQuery.new(Ticket.all, status: 'solved')
    tickets(:disqus).update!(status: 'solved')

    assert_equal [tickets(:disqus)], query.call
  end

  test 'defaults to open status by default' do
    query = TicketsQuery.new(Ticket.all, status: '')
    tickets(:disqus).update!(status: 'solved')

    assert_equal [tickets(:twitter), tickets(:external)], query.call
  end

  test 'filters by assignee' do
    query = TicketsQuery.new(Ticket.all, assignee: users(:john).id)

    assert_equal [tickets(:twitter)], query.call
  end

  test 'filters by tag' do
    tickets(:twitter).tag_list.add('hello')
    tickets(:twitter).save!
    query = TicketsQuery.new(Ticket.all, tag: 'hello')

    assert_equal [tickets(:twitter)], query.call
  end

  test 'filters by author' do
    query = TicketsQuery.new(Ticket.all, author: 'robert_is_cool')

    assert_equal [tickets(:disqus)], query.call
  end

  test 'filters by content' do
    query = TicketsQuery.new(Ticket.all, content: 'Internal twitter ticket content.')

    assert_equal [tickets(:twitter)], query.call
  end
end
