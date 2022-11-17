# frozen_string_literal: true

require 'test_helper'

class DisqusTest < ActiveSupport::TestCase
  test '#new_mentions makes a disqus api request for all posts when a ticket identifier is not provided' do
    client = Clients::Disqus.new('api_key', 'api_secret', 'token')

    disqus_list_forums_request = stub_request(:get, 'https://disqus.com/api/3.0/users/listForums.json?access_token=token&api_key=api_key&api_secret=api_secret&order=asc')
      .and_return(
        status: 200, body: file_fixture('disqus_list_forums.json').read
      )

    disqus_list_posts_request = stub_request(:get, 'https://disqus.com/api/3.0/posts/list.json?access_token=token&api_key=api_key&api_secret=api_secret&forum=bobross&order=asc')
      .and_return(status: 200, body: file_fixture('disqus_posts_list.json').read)

    client.new_mentions(nil)

    assert_requested(disqus_list_forums_request)
    assert_requested(disqus_list_posts_request)
  end

  test '#new_mentions makes a disqus api request with the since parameter when provided' do
    client = Clients::Disqus.new('api_key', 'api_secret', 'token')

    disqus_list_forums_request = stub_request(:get, 'https://disqus.com/api/3.0/users/listForums.json?access_token=token&api_key=api_key&api_secret=api_secret&order=asc')
      .and_return(
        status: 200, body: file_fixture('disqus_list_forums.json').read
      )

    disqus_list_posts_request = stub_request(:get, 'https://disqus.com/api/3.0/posts/list.json?access_token=token&api_key=api_key&api_secret=api_secret&forum=bobross&order=asc&since=disqus_uid')
      .and_return(status: 200, body: file_fixture('disqus_posts_list.json').read)

    client.new_mentions('disqus_uid')

    assert_requested(disqus_list_forums_request)
    assert_requested(disqus_list_posts_request)
  end

  test '#reply makes a disqus api request' do
    client = Clients::Disqus.new('api_key', 'api_secret', 'token')

    disqus_create_request = stub_request(:post, 'https://disqus.com/api/3.0/posts/create.json')
      .with(
        body: { 'access_token' => 'token', 'api_key' => 'api_key', 'api_secret' => 'api_secret',
                'message' => 'response', 'parent' => 'disqus_uid' }
      ).and_return(status: 200, body: file_fixture('disqus_post.json').read)

    client.reply('response', 'disqus_uid')

    assert_requested(disqus_create_request)
  end

  test '#delete makes a disqus api request' do
    client = Clients::Disqus.new('api_key', 'api_secret', 'token')

    disqus_remove_request = stub_request(:post, 'https://disqus.com/api/3.0/posts/remove.json')
      .with(
        body: { 'access_token' => 'token', 'api_key' => 'api_key', 'api_secret' => 'api_secret',
                'post' => 'disqus_uid' }
      ).and_return(status: 200, body: file_fixture('disqus_remove_post.json').read)

    client.delete('disqus_uid')

    assert_requested(disqus_remove_request)
  end

  test '#permalink makes a disqus api request' do
    client = Clients::Disqus.new('api_key', 'api_secret', 'token')

    disqus_permalink_request = stub_request(:get, 'https://disqus.com/api/3.0/posts/details.json?access_token=token&api_key=api_key&api_secret=api_secret&post=disqus_uid&related=thread').and_return(
      status: 200, body: file_fixture('disqus_post.json').read
    )

    assert_instance_of String, client.permalink('disqus_uid')
    assert_requested(disqus_permalink_request)
  end
end
