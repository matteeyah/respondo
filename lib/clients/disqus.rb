# frozen_string_literal: true

module Clients
  class Disqus < Clients::Client
    def initialize(api_key, api_secret, access_token)
      @api_key = api_key
      @api_secret = api_secret
      @access_token = access_token
    end

    def new_mentions(last_ticket_identifier)
      options_hash = { forum: forum, order: :asc, api_key: @api_key, api_secret: @api_secret, access_token: @access_token }
      options_hash[:since] = last_ticket_identifier if last_ticket_identifier

      ::DisqusApi.v3.posts.list(options_hash).response
    end

    private

    def forum
      @forum ||=
        ::DisqusApi.v3.users.listForums(
          order: :asc, api_key: @api_key, api_secret: @api_secret, access_token: @access_token
        ).response.first['id']
    end
  end
end
