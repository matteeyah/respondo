# typed: false
# frozen_string_literal: true

module Clients
  class Twitter < Twitter::REST::Client
    def reply(response_text, tweet_id)
      update(response_text, in_reply_to_status_id: tweet_id, auto_populate_reply_metadata: true)
    end
  end
end
