# frozen_string_literal: true

module Clients
  X_HOME = 'https://x.com'
  X_POST = "#{X_HOME}/twitter/status".freeze

  class X < Clients::ProviderClient
    TWEET_PARAMS = {
      'tweet.fields' => 'created_at',
      'expansions' => 'author_id,referenced_tweets.id'
    }.freeze

    def initialize(api_key, api_secret, token, secret)
      super()

      @api_key = api_key
      @api_secret = api_secret
      @token = token
      @secret = secret
    end

    def new_mentions(last_mention_identifier) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      id = x_client.get('users/me')['data']['id']
      mentions = []
      users = []

      new_mentions = list_mentions(id, last_mention_identifier)
      return [] unless new_mentions

      while new_mentions[:pagination_token]
        mentions += new_mentions[:mentions]
        users += new_mentions[:users]
        new_mentions = list_mentions(id, last_mention_identifier, new_mentions[:pagination_token])
      end
      mentions += new_mentions[:mentions]
      users += new_mentions[:users]
      users.uniq! { |user| user['id'] }

      mentions.map do |mention|
        parse_response(mention, users)
      end.reverse
    end

    def reply(response_text, tweet_id)
      new_reply = x_client.post(
        'tweets', { text: response_text, reply: { in_reply_to_tweet_id: tweet_id } }.to_json
      )
      api_response = x_client.get("tweets/#{new_reply['data']['id']}?#{TWEET_PARAMS.to_query}")
      parse_response(api_response['data'], api_response['includes']['users'])
    end

    def delete(tweet_id)
      x_client.delete("tweets/#{tweet_id}")
    end

    private

    def x_client
      @x_client ||=
        ::X::Client.new(
          api_key: @api_key,
          api_key_secret: @api_secret,
          access_token: @token,
          access_token_secret: @secret
        )
    end

    def list_mentions(user_id, last_mention_identifier = nil, pagination_token = nil)
      tweet_params = TWEET_PARAMS.dup
      tweet_params['since_id'] = last_mention_identifier if last_mention_identifier
      tweet_params['pagination_token'] = pagination_token if pagination_token

      api_response = x_client.get("users/#{user_id}/mentions?#{tweet_params.to_param}")
      return nil if api_response['meta']['result_count'].zero?

      {
        mentions: api_response['data'],
        users: api_response['includes']['users'],
        pagination_token: api_response['meta']['next_token']
      }
    end

    def parse_response(api_response, user_includes) # rubocop:disable Metrics/MethodLength
      author_username = user_includes.find { |ui| ui['id'] == api_response['author_id'] }['username']
      {
        external_uid: api_response['id'], content: api_response['text'], created_at: api_response['created_at'],
        parent_uid: api_response['referenced_tweets']&.find { |ref| ref['type'] == 'replied_to' }&.dig('id'),
        external_link: "#{X_POST}/#{api_response['id']}",
        author: {
          external_uid: api_response['author_id'],
          username: author_username,
          external_link: "#{X_HOME}/#{author_username}"
        }
      }
    end
  end
end
