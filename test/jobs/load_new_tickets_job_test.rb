# frozen_string_literal: true

require 'test_helper'

require 'minitest/mock'

class LoadNewTicketsJobTest < ActiveJob::TestCase
  def setup
    stub_twitter
    stub_disqus
  end

  test 'creates tickets' do
    assert_equal 3, Ticket.count
    LoadNewTicketsJob.perform_now(brands(:respondo))

    assert_equal 5, Ticket.count
  end

  private

  def stub_twitter
    twitter_ticket = tickets(:internal_twitter)

    stub_request(:post, 'https://api.twitter.com/oauth2/token').to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: { token_type: 'bearer', access_token: 'HELLO' }.to_json
    )
    stub_request(:get, "https://api.twitter.com/1.1/statuses/mentions_timeline.json?since_id=#{twitter_ticket.external_uid}&tweet_mode=extended").to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('twitter_mentions_timeline.json').read
    )
  end

  def stub_disqus
    disqus_ticket = tickets(:internal_disqus)

    stub_request(:get, 'https://disqus.com/api/3.0/users/listForums.json?access_token&api_key&api_secret&order=asc').to_return(
      status: 200,
      body: file_fixture('disqus_list_forums.json').read
    )
    stub_request(:get, "https://disqus.com/api/3.0/posts/list.json?access_token&api_key&api_secret&forum=bobross&order=asc&since=#{disqus_ticket.created_at.utc.iso8601}").to_return(
      status: 200,
      body: file_fixture('disqus_posts_list.json').read
    )
  end
end
