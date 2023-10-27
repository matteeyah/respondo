# frozen_string_literal: true

require 'test_helper'

class TwitterTest < ActiveSupport::TestCase
  test '#new_mentions makes a twitter api request for all posts when a ticket identifier is not provided' do
    client = Clients::Twitter.new('api_key', 'api_secret', 'token', 'secret')

    stub_request(:get, 'https://api.twitter.com/2/users/me').to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('twitter_users_me.json')
    )
    twitter_new_mentions_request = stub_request(:get, 'https://api.twitter.com/2/users/2244994945/mentions?expansions=author_id,referenced_tweets.id&max_results=5&tweet.fields=created_at&user.fields=created_at')
      .and_return(
        status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
        body: file_fixture('twitter_mentions.json').read
      )

    client.new_mentions(nil)

    assert_requested(twitter_new_mentions_request)
  end

  test '#new_mentions makes a twitter api request with the since parameter when provided' do
    client = Clients::Twitter.new('api_key', 'api_secret', 'token', 'secret')

    stub_request(:get, 'https://api.twitter.com/2/users/me').to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('twitter_users_me.json')
    )
    twitter_new_mentions_request = stub_request(:get, 'https://api.twitter.com/2/users/2244994945/mentions?expansions=author_id,referenced_tweets.id&max_results=5&since_id=1&tweet.fields=created_at&user.fields=created_at')
      .and_return(
        status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
        body: file_fixture('twitter_mentions.json').read
      )

    client.new_mentions(1)

    assert_requested(twitter_new_mentions_request)
  end

  test '#reply makes a twitter api request' do
    client = Clients::Twitter.new('api_key', 'api_secret', 'token', 'secret')

    stub_request(:get, 'https://api.twitter.com/2/tweets/1445880548472328192?expansions=author_id,referenced_tweets.id&tweet.fields=created_at&user.fields=created_at').and_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('twitter_get_tweet.json').read
    )
    twitter_reply_request = stub_request(:post, 'https://api.twitter.com/2/tweets')
      .with(body: { text: 'response', reply: { in_reply_to_tweet_id: 1 } }.to_json)
      .and_return(
        status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
        body: file_fixture('twitter_create_tweet.json').read
      )

    client.reply('response', 1)

    assert_requested(twitter_reply_request)
  end

  test '#delete makes a twitter api request' do
    client = Clients::Twitter.new('api_key', 'api_secret', 'token', 'secret')

    twitter_delete_request = stub_request(:delete, 'https://api.twitter.com/2/tweets/1')
      .and_return(
        status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
        body: file_fixture('twitter_delete_tweet.json').read
      )

    client.delete(1)

    assert_requested(twitter_delete_request)
  end

  test '#permalink generates a twitter url' do
    client = Clients::Twitter.new('api_key', 'api_secret', 'token', 'secret')

    assert_equal 'https://x.com/twitter/status/1', client.permalink(1)
  end
end
