# frozen_string_literal: true

module Clients
  class External < Clients::Client
    def initialize(response_url)
      @response_url = response_url
    end

    def reply(response_text, parent_external_post_id)
      Net::HTTP.post_form(URI(@response_url), response_text: response_text, parent_id: parent_external_post_id).body
    end
  end
end
