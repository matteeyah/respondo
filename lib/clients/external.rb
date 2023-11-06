# frozen_string_literal: true

module Clients
  class External < Clients::ProviderClient
    def initialize(external_link)
      super()

      @external_link = external_link
    end

    def reply(response_text, parent_external_post_id)
      request = Net::HTTP::Post.new(uri.path)
      request.set_form_data(
        response_text:,
        parent_id: parent_external_post_id
      )

      send_request!(request)
    end

    def delete(_external_uid)
      send_request!(Net::HTTP::Delete.new(uri.path))
    end

    def permalink(_link)
      @external_link
    end

    private

    def uri
      @uri ||= URI(@external_link)
    end

    def http_client
      Net::HTTP.new(uri.host, uri.port).tap do |net_http|
        net_http.use_ssl = true
      end
    end

    def send_request!(request)
      JSON.parse(http_client.request(request).body).deep_symbolize_keys
    end
  end
end
