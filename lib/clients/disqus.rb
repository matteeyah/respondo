# frozen_string_literal: true

module Clients
  class Disqus < Clients::Client
    def initialize(api_key, api_secret, access_token)
      super()

      @api_key = api_key
      @api_secret = api_secret
      @access_token = access_token
    end

    def new_mentions(last_ticket_identifier)
      options_hash = { forum: forum, order: :asc }.merge(permission_params)
      options_hash[:since] = last_ticket_identifier if last_ticket_identifier

      ::DisqusApi.v3.posts.list(options_hash).response
    end

    def reply(response_text, disqus_post_id)
      options_hash = { parent: disqus_post_id, message: response_text }.merge(permission_params)

      ::DisqusApi.v3.posts.create(options_hash).response
    end

    private

    def forum
      @forum ||=
        ::DisqusApi.v3.users.listForums(
          order: :asc, api_key: @api_key, api_secret: @api_secret, access_token: @access_token
        ).response.first['id']
    end

    def permission_params
      { api_key: @api_key, api_secret: @api_secret, access_token: @access_token }
    end
  end
end
