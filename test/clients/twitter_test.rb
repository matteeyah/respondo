# frozen_string_literal: true

require 'test_helper'

class TwitterTest < ActiveSupport::TestCase
  test '#new_mentions makes a twitter api request for all posts when a ticket identifier is not provided' do
    client = Clients::Twitter.new('api_key', 'api_secret', 'token', 'secret')

    twitter_new_mentions_request = stub_request(:get, 'https://api.twitter.com/1.1/statuses/mentions_timeline.json?tweet_mode=extended')
      .and_return(
        status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
        body: file_fixture('twitter_mentions_timeline.json').read
      )

    client.new_mentions(nil)

    assert_requested(twitter_new_mentions_request)
  end

  test '#new_mentions makes a twitter api request with the since parameter when provided' do
    client = Clients::Twitter.new('api_key', 'api_secret', 'token', 'secret')

    twitter_new_mentions_request = stub_request(:get, 'https://api.twitter.com/1.1/statuses/mentions_timeline.json?since_id=1&tweet_mode=extended')
      .and_return(
        status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
        body: file_fixture('twitter_mentions_timeline.json').read
      )

    client.new_mentions(1)

    assert_requested(twitter_new_mentions_request)
  end

  test '#reply makes a twitter api request' do
    client = Clients::Twitter.new('api_key', 'api_secret', 'token', 'secret')

    twitter_reply_request = stub_request(:post, 'https://api.twitter.com/1.1/statuses/update.json')
      .with(body: { 'auto_populate_reply_metadata' => 'true', 'in_reply_to_status_id' => '1', 'status' => 'response',
                    'tweet_mode' => 'extended' })
      .and_return(
        status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
        body: file_fixture('twitter_post.json').read
      )

    client.reply('response', 1)

    assert_requested(twitter_reply_request)
  end

  test '#delete makes a twitter api request' do
    client = Clients::Twitter.new('api_key', 'api_secret', 'token', 'secret')

    twitter_delete_request = stub_request(:post, 'https://api.twitter.com/1.1/statuses/destroy/1.json')
      .and_return(
        status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
        body: file_fixture('twitter_post.json').read
      )

    client.delete(1)

    assert_requested(twitter_delete_request)
  end

  test '#permalink makes a twitter api request' do
    client = Clients::Twitter.new('api_key', 'api_secret', 'token', 'secret')

    twitter_permalink_request = stub_request(:get, 'https://api.twitter.com/1.1/statuses/show/1.json')
      .and_return(
        status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
        body: file_fixture('twitter_post.json').read
      )

    client.permalink(1)

    assert_requested(twitter_permalink_request)
  end
end
