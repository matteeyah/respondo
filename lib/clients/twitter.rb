# frozen_string_literal: true

module Clients
  class Twitter < Clients::Client
    def initialize(api_key, api_secret, token, secret)
      @api_key = api_key
      @api_secret = api_secret
      @token = token
      @secret = secret
    end

    def new_mentions(last_ticket_identifier)
      options_hash = { tweet_mode: 'extended' }
      options_hash[:since_id] = last_ticket_identifier if last_ticket_identifier
      twitter_client.mentions_timeline(options_hash)
    end

    def reply(response_text, tweet_id)
      twitter_client.update(response_text, in_reply_to_status_id: tweet_id, auto_populate_reply_metadata: true, tweet_mode: 'extended')
    end

    private

    def twitter_client
      @twitter_client ||=
        ::Twitter::REST::Client.new do |config|
          config.consumer_key = @api_key
          config.consumer_secret = @api_secret
          config.access_token = @token
          config.access_token_secret = @secret
        end
    end
  end
end
