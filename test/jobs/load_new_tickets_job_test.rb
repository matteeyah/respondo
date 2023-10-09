# frozen_string_literal: true

require 'test_helper'

require 'minitest/mock'

class LoadNewTicketsJobTest < ActiveJob::TestCase
  setup do
    stub_twitter
  end

  test 'creates tickets' do
    assert_difference -> { Ticket.count }, 1 do
      LoadNewTicketsJob.perform_now(organizations(:respondo))
    end
  end

  private

  def stub_twitter
    twitter_ticket = tickets(:twitter)

    stub_request(:post, 'https://api.twitter.com/oauth2/token').to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: { token_type: 'bearer', access_token: 'HELLO' }.to_json
    )
    stub_request(:get, "https://api.twitter.com/1.1/statuses/mentions_timeline.json?since_id=#{twitter_ticket.external_uid}&tweet_mode=extended").to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('twitter_mentions_timeline.json').read
    )
  end
end
