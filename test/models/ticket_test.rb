# frozen_string_literal: true

require 'test_helper'

class TicketTest < ActiveSupport::TestCase
  test 'validates presence of external_uid' do
    ticket = tickets(:x)
    ticket.external_uid = nil

    assert_predicate ticket, :invalid?
  end

  test 'validates presence of content' do
    ticket = tickets(:x)
    ticket.content = nil

    assert_predicate ticket, :invalid?
  end

  test 'validates uniqueness of external_uid scoped to ticketable_type and organization_id' do
    ticket = tickets(:x).dup

    assert_predicate ticket, :invalid?
    ticket.errors.added?(:external_uid, :taken, value: 'uid_1')
  end

  test '.root returnes tickets without a parent' do
    child = Ticket.create!(external_uid: 'uid_10', parent: tickets(:x), content: 'hello',
                           author: authors(:james), organization: organizations(:respondo),
                           ticketable: internal_tickets(:x))

    assert_not_includes Ticket.root, child
  end

  test '.with_descendants_hash' do
    first_child = Ticket.create!(
      external_uid: 'uid_10', parent: tickets(:x), content: 'hello',
      author: authors(:james), organization: organizations(:respondo), ticketable: internal_tickets(:x)
    )

    second_child = Ticket.create!(
      external_uid: 'uid_11', parent: tickets(:external), content: 'hello',
      author: authors(:james), organization: organizations(:respondo), ticketable: external_tickets(:default)
    )

    expected_structure = {
      tickets(:x) => { first_child => {} },
      tickets(:external) => { second_child => {} },
      tickets(:email) => {}
    }

    assert_equal expected_structure, Ticket.root.with_descendants_hash
  end

  test '#with_descendants_hash' do
    child = Ticket.create!(external_uid: 'uid_10', parent: tickets(:x), content: 'hello',
                           author: authors(:james), organization: organizations(:respondo),
                           ticketable: internal_tickets(:x))

    expected_structure = {
      tickets(:x) => { child => {} }
    }

    assert_equal expected_structure, tickets(:x).with_descendants_hash
  end

  test '#respond_as creates a response ticket' do
    ticket = tickets(:x)
    organization_accounts(:x).update!(token: 'hello', secret: 'world')
    ticket.update!(external_uid: '1')

    stub_request(:get, 'https://api.twitter.com/2/tweets/1445880548472328192?expansions=author_id,referenced_tweets.id&tweet.fields=created_at&user.fields=created_at').and_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('x_get_tweet.json').read
    )
    stub_request(:post, 'https://api.twitter.com/2/tweets').with(
      body: { text: 'response', reply: { in_reply_to_tweet_id: '1' } }.to_json
    ).and_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('x_create_tweet.json').read
    )

    assert_difference -> { Ticket.count }, 1 do
      ticket.respond_as(users(:john), 'response')
    end
  end
end
