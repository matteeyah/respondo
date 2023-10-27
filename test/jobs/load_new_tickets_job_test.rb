# frozen_string_literal: true

require 'test_helper'

require 'minitest/mock'

class LoadNewTicketsJobTest < ActiveJob::TestCase
  setup do
    stub_x
  end

  test 'creates tickets' do
    assert_difference -> { Ticket.count }, 5 do
      LoadNewTicketsJob.perform_now(organizations(:respondo))
    end
  end

  private

  def stub_x
    x_ticket = tickets(:x)

    stub_request(:get, 'https://api.twitter.com/2/users/me').to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('x_users_me.json')
    )
    stub_request(:get, "https://api.twitter.com/2/users/2244994945/mentions?expansions=author_id,referenced_tweets.id&max_results=5&since_id=#{x_ticket.external_uid}&tweet.fields=created_at&user.fields=created_at").to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('x_mentions.json').read
    )
  end
end
