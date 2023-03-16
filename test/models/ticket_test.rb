# frozen_string_literal: true

require 'test_helper'

class TicketTest < ActiveSupport::TestCase
  test 'validates presence of external_uid' do
    ticket = tickets(:twitter)
    ticket.external_uid = nil

    assert_predicate ticket, :invalid?
  end

  test 'validates presence of content' do
    ticket = tickets(:twitter)
    ticket.content = nil

    assert_predicate ticket, :invalid?
  end

  test 'validates uniqueness of external_uid scoped to ticketable_type and organization_id' do
    ticket = tickets(:twitter).dup

    assert_predicate ticket, :invalid?
    ticket.errors.added?(:external_uid, :taken, value: 'uid_1')
  end

  test '.root returnes tickets without a parent' do
    child = Ticket.create!(external_uid: 'uid_10', parent: tickets(:twitter), content: 'hello',
                           author: authors(:james), organization: organizations(:respondo),
                           ticketable: internal_tickets(:twitter))

    assert_not_includes Ticket.root, child
  end

  test '.from_client_response! returns a ticket' do
    client_response = Struct.new(:id, :attrs, :user, :in_reply_to_tweet_id, :created_at)
      .new(
        2, { full_text: 'hello world' },
        Struct.new(:id, :screen_name).new(123_456, 'doesnotmatter'),
        1, '2019-01-01T00:23:39.951Z'
      )

    assert_instance_of Ticket,
                       Ticket.from_client_response!('twitter', client_response, organization_accounts(:twitter), nil)
  end

  test '.from_client_response! assigns parent to ticket' do
    client_response = Struct.new(:id, :attrs, :user, :in_reply_to_tweet_id, :created_at)
      .new(
        2, { full_text: 'hello world' },
        Struct.new(:id, :screen_name).new(123_456, 'doesnotmatter'),
        1, '2019-01-01T00:23:39.951Z'
      )
    parent = tickets(:twitter)
    parent.update!(external_uid: 1)

    created_ticket = Ticket.from_client_response!('twitter', client_response, organization_accounts(:twitter), nil)

    assert_includes parent.replies, created_ticket
  end

  test '.from_client_response! assigns creator to ticket' do
    client_response = Struct.new(:id, :attrs, :user, :in_reply_to_tweet_id, :created_at)
      .new(
        2, { full_text: 'hello world' },
        Struct.new(:id, :screen_name).new(123_456, 'doesnotmatter'),
        1, '2019-01-01T00:23:39.951Z'
      )

    created_ticket = Ticket.from_client_response!('twitter', client_response, organization_accounts(:twitter),
                                                  users(:john))

    assert_equal users(:john), created_ticket.creator
  end

  test '.with_descendants_hash' do
    first_child = Ticket.create!(
      external_uid: 'uid_10', parent: tickets(:twitter), content: 'hello',
      author: authors(:james), organization: organizations(:respondo), ticketable: internal_tickets(:twitter)
    )

    second_child = Ticket.create!(
      external_uid: 'uid_11', parent: tickets(:disqus), content: 'hello',
      author: authors(:james), organization: organizations(:respondo), ticketable: internal_tickets(:disqus)
    )

    expected_structure = {
      tickets(:twitter) => { first_child => {} },
      tickets(:disqus) => { second_child => {} },
      tickets(:external) => {}
    }

    assert_equal expected_structure, Ticket.root.with_descendants_hash
  end

  test '#with_descendants_hash' do
    child = Ticket.create!(external_uid: 'uid_10', parent: tickets(:twitter), content: 'hello',
                           author: authors(:james), organization: organizations(:respondo),
                           ticketable: internal_tickets(:twitter))

    expected_structure = {
      tickets(:twitter) => { child => {} }
    }

    assert_equal expected_structure, tickets(:twitter).with_descendants_hash
  end

  test '#respond_as creates a response ticket' do
    ticket = tickets(:twitter)
    organization_accounts(:twitter).update!(token: 'hello', secret: 'world')
    ticket.update!(external_uid: '1')

    stub_request(:post, 'https://api.twitter.com/1.1/statuses/update.json').with(
      body: {
        'auto_populate_reply_metadata' => 'true', 'in_reply_to_status_id' => '1',
        'status' => 'response', 'tweet_mode' => 'extended'
      }
    ).and_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('twitter_post.json').read
    )

    assert_difference -> { Ticket.count }, 1 do
      ticket.respond_as(users(:john), 'response')
    end
  end
end
