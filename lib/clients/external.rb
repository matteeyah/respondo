# frozen_string_literal: true

module Clients
  class External < Clients::Client
    def initialize(response_url, author_external_uid, author_username)
      super()

      @response_url = response_url
      @author_external_uid = author_external_uid
      @author_username = author_username
    end

    def reply(response_text, parent_external_post_id)
      Net::HTTP.post_form(
        URI(@response_url),
        response_text: response_text,
        parent_id: parent_external_post_id,
        author: { external_uid: @author_external_uid, username: @author_username }
      ).body
    end
  end
end
