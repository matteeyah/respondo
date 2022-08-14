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
      request = Net::HTTP::Post.new(uri.path)
      request.set_form_data(
        response_text:,
        parent_id: parent_external_post_id,
        author: { external_uid: @author_external_uid, username: @author_username }
      )

      http_client.request(request).body
    end

    def delete
      request = Net::HTTP::Delete.new(uri.path)
      http_client.request(request).body
    end

    private

    def uri
      @uri ||= URI(@response_url)
    end

    def http_client
      Net::HTTP.new(uri.host, uri.port)
    end
  end
end
