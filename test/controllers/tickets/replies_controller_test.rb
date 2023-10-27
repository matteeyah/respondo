# frozen_string_literal: true

require 'test_helper'

require 'support/authentication_request_helper'

module Tickets
  class RepliesControllerTest < ActionDispatch::IntegrationTest
    include AuthenticationRequestHelper

    test 'POST create when the user is authorized redirects the user to edit page' do
      sign_in(users(:john), user_accounts(:google_oauth2))
      organizations(:respondo).users << users(:john)

      organization_accounts(:twitter).update!(token: 'hello', secret: 'world')

      stub_request(:get, 'https://api.twitter.com/2/tweets/1445880548472328192?expansions=author_id,referenced_tweets.id&tweet.fields=created_at&user.fields=created_at').and_return(
        status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
        body: file_fixture('twitter_get_tweet.json').read
      )
      twitter_reply_request = stub_request(:post, 'https://api.twitter.com/2/tweets')
        .with(body: { text: 'hello', reply: { in_reply_to_tweet_id: 'uid_1' } }.to_json)
        .to_return(
          body: file_fixture('twitter_create_tweet.json').read,
          headers: { 'Content-Type' => 'application/json' }
        )

      post "/tickets/#{tickets(:twitter).id}/replies",
           params: { ticket: { content: 'hello' } }

      assert_redirected_to tickets_path
    end

    test 'POST create when the user is not authorized redirects the user to root path' do
      sign_in(users(:john), user_accounts(:google_oauth2))

      post "/tickets/#{tickets(:twitter).id}/replies"

      assert_redirected_to root_path
    end

    test 'POST create when the user is not signed in redirects the user to login path' do
      post "/tickets/#{tickets(:twitter).id}/replies"

      assert_redirected_to login_path
    end
  end
end
