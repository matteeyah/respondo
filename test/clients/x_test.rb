# frozen_string_literal: true

require 'test_helper'

class XTest < ActiveSupport::TestCase
  test '#new_mentions makes a x api request for all posts when a ticket identifier is not provided' do
    client = Clients::X.new('api_key', 'api_secret', 'token', 'secret')

    stub_request(:get, 'https://api.twitter.com/2/users/me').to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('x_users_me.json')
    )
    x_new_mentions_request = stub_request(:get, 'https://api.twitter.com/2/users/2244994945/mentions?expansions=author_id,referenced_tweets.id&tweet.fields=created_at')
      .and_return(
        status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
        body: file_fixture('x_mentions.json').read
      )

    client.new_mentions(nil)

    assert_requested(x_new_mentions_request)
  end

  test '#new_mentions makes a x api request with the since parameter when provided' do
    client = Clients::X.new('api_key', 'api_secret', 'token', 'secret')

    stub_request(:get, 'https://api.twitter.com/2/users/me').to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('x_users_me.json')
    )
    x_new_mentions_request = stub_request(:get, 'https://api.twitter.com/2/users/2244994945/mentions?expansions=author_id,referenced_tweets.id&since_id=1&tweet.fields=created_at')
      .and_return(
        status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
        body: file_fixture('x_mentions.json').read
      )

    client.new_mentions(1)

    assert_requested(x_new_mentions_request)
  end

  test '#new_mentions users pagination to load all results' do
    client = Clients::X.new('api_key', 'api_secret', 'token', 'secret')

    stub_request(:get, 'https://api.twitter.com/2/users/me').to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('x_users_me.json')
    )
    stub_request(:get, 'https://api.twitter.com/2/users/2244994945/mentions?expansions=author_id,referenced_tweets.id&since_id=1&tweet.fields=created_at')
      .and_return(
        status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
        body: file_fixture('x_mentions_first_page.json').read
      )
    stub_request(:get, 'https://api.twitter.com/2/users/2244994945/mentions?expansions=author_id,referenced_tweets.id&since_id=1&tweet.fields=created_at&pagination_token=7140dibdnow9c7btw3w3y5b6jqjnk3k4g5zkmfkvqwa42')
      .and_return(
        status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
        body: file_fixture('x_mentions_second_page.json').read
      )

    assert_equal 2, client.new_mentions(1).count
  end

  test '#new_mentions returns an empty array when there are no new mentions' do
    client = Clients::X.new('api_key', 'api_secret', 'token', 'secret')

    stub_request(:get, 'https://api.twitter.com/2/users/me').to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('x_users_me.json')
    )
    stub_request(:get, 'https://api.twitter.com/2/users/2244994945/mentions?expansions=author_id,referenced_tweets.id&since_id=1&tweet.fields=created_at')
      .and_return(
        status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
        body: file_fixture('x_mentions_empty.json').read
      )

    assert_empty client.new_mentions(1)
  end

  test '#reply makes a x api request' do
    client = Clients::X.new('api_key', 'api_secret', 'token', 'secret')

    stub_request(:get, 'https://api.twitter.com/2/tweets/1445880548472328192?expansions=author_id,referenced_tweets.id&tweet.fields=created_at').and_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('x_get_tweet.json').read
    )
    x_reply_request = stub_request(:post, 'https://api.twitter.com/2/tweets')
      .with(body: { text: 'response', reply: { in_reply_to_tweet_id: 1 } }.to_json)
      .and_return(
        status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
        body: file_fixture('x_create_tweet.json').read
      )

    client.reply('response', 1)

    assert_requested(x_reply_request)
  end

  test '#delete makes a x api request' do
    client = Clients::X.new('api_key', 'api_secret', 'token', 'secret')

    x_delete_request = stub_request(:delete, 'https://api.twitter.com/2/tweets/1')
      .and_return(
        status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
        body: file_fixture('x_delete_tweet.json').read
      )

    client.delete(1)

    assert_requested(x_delete_request)
  end

  test '#permalink generates a x url' do
    client = Clients::X.new('api_key', 'api_secret', 'token', 'secret')

    assert_equal 'https://x.com/twitter/status/1', client.permalink(1)
  end
end
