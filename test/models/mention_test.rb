# frozen_string_literal: true

require 'test_helper'

class MentionTest < ActiveSupport::TestCase
  test 'validates presence of external_uid' do
    mention = mentions(:x)
    mention.external_uid = nil

    assert_predicate mention, :invalid?
  end

  test 'validates presence of content' do
    mention = mentions(:x)
    mention.content = nil

    assert_predicate mention, :invalid?
  end

  test '.root returnes mentions without a parent' do
    child = Mention.create!(external_uid: 'uid_10', parent: mentions(:x), content: 'hello',
                           author: authors(:james), organization: organizations(:respondo),
                           source: organization_accounts(:x),
                           external_link: 'https://x.com/twitter/status/uid_1')

    assert_not_includes Mention.root, child
  end

  test '.with_descendants_hash' do
    first_child = Mention.create!(
      external_uid: 'uid_10', parent: mentions(:x), content: 'hello',
      author: authors(:james), organization: organizations(:respondo),
      source: organization_accounts(:x),
      external_link: 'https://x.com/twitter/status/uid_1'
    )

    second_child = Mention.create!(
      external_uid: 'uid_11', parent: mentions(:linkedin), content: 'hello',
      author: authors(:james), organization: organizations(:respondo),
      source: organization_accounts(:linkedin),
      external_link: 'https://x.com/twitter/status/uid_1'
    )

    expected_structure = {
      mentions(:x) => { first_child => {} },
      mentions(:linkedin) => { second_child => {} }
    }

    assert_equal expected_structure, Mention.root.with_descendants_hash
  end

  test '#with_descendants_hash' do
    child = Mention.create!(external_uid: 'uid_10', parent: mentions(:x), content: 'hello',
                           author: authors(:james), organization: organizations(:respondo),
                           source: organization_accounts(:x),
                           external_link: 'https://x.com/twitter/status/uid_1')

    expected_structure = {
      mentions(:x) => { child => {} }
    }

    assert_equal expected_structure, mentions(:x).with_descendants_hash
  end

  test '#respond_as creates a response mention' do
    mention = mentions(:x)
    organization_accounts(:x).update!(token: 'hello', secret: 'world')
    mention.update!(external_uid: '1')

    stub_request(:get, 'https://api.twitter.com/2/tweets/1445880548472328192?expansions=author_id,referenced_tweets.id&tweet.fields=created_at').and_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('x_get_tweet.json').read
    )
    stub_request(:post, 'https://api.twitter.com/2/tweets').with(
      body: { text: 'response', reply: { in_reply_to_tweet_id: '1' } }.to_json
    ).and_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('x_create_tweet.json').read
    )

    assert_difference -> { Mention.count }, 1 do
      mention.respond_as(users(:john), 'response')
    end
  end
end
