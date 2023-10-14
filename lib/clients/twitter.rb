# frozen_string_literal: true

module Clients
  class Twitter < Clients::ProviderClient
    def initialize(api_key, api_secret, token, secret)
      super()

      @api_key = api_key
      @api_secret = api_secret
      @token = token
      @secret = secret
    end

    def new_mentions(last_ticket_identifier)
      id = twitter_client.get('users/me')['data']['id']
      query_string = <<~QUERY_STRING
        users/#{id}/mentions?tweet.fields=created_at&expansions=author_id,referenced_tweets.id&user.fields=created_at&max_results=5
      QUERY_STRING
      query_string += "&since_id=#{last_ticket_identifier}" if last_ticket_identifier
      api_response = twitter_client.get(query_string)
      api_response['data'].map do |mention|
        parse_response(mention, api_response['includes']['users'])
      end.reverse
    end

    def reply(response_text, tweet_id)
      new_reply = twitter_client.post(
        'tweets', { text: response_text, reply: { in_reply_to_tweet_id: tweet_id } }.to_json
      )
      api_response = twitter_client.get(<<~QUERY_STRING)
        tweets/#{new_reply['data']['id']}?tweet.fields=created_at&expansions=author_id,referenced_tweets.id&user.fields=created_at
      QUERY_STRING
      parse_response(api_response['data'], api_response['includes']['users'])
    end

    def delete(tweet_id)
      twitter_client.delete("tweets/#{tweet_id}")
    end

    def permalink(tweet_id)
      "https://x.com/twitter/status/#{tweet_id}"
    end

    private

    def twitter_client
      @twitter_client ||=
        ::X::Client.new(
          api_key: @api_key,
          api_key_secret: @api_secret,
          access_token: @token,
          access_token_secret: @secret
        )
    end

    def parse_response(api_response, user_includes)
      {
        external_uid: api_response['id'], content: api_response['text'], created_at: api_response['created_at'],
        parent_uid: api_response['referenced_tweets']&.find { |ref| ref['type'] == 'replied_to' }&.dig('id'),
        author: { external_uid: api_response['author_id'], username: user_includes.find do |ui|
                                                                       ui['id'] == api_response['author_id']
                                                                     end['username'] }
      }
    end
  end
end
