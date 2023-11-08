# frozen_string_literal: true

require 'test_helper'

require 'minitest/mock'

class LoadNewTicketsJobTest < ActiveJob::TestCase
  setup do
    stub_x
    stub_li
  end

  test 'creates tickets' do
    assert_difference -> { Ticket.count }, 6 do
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
    stub_request(:get, "https://api.twitter.com/2/users/2244994945/mentions?expansions=author_id,referenced_tweets.id&since_id=#{x_ticket.external_uid}&tweet.fields=created_at").to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('x_mentions.json').read
    )
  end

  def stub_li # rubocop:disable Metrics/MethodLength
    stub_request(:get, 'https://api.linkedin.com/v2/organizationalEntityAcls?projection=(elements*(organizationalTarget~(id)))&q=roleAssignee&role=ADMINISTRATOR').to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('li_admin_organizations.json')
    )
    stub_request(:get, %r{https://api\.linkedin\.com/v2/organizationalEntityNotifications\?actions=List\(SHARE_MENTION\)&organizationalEntity=urn:li:organization:100702332&q=criteria&timeRange=\(start:\d+,end:\d+\)}).to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('li_organization_notifications.json')
    )
    stub_request(:get, 'https://api.linkedin.com/v2/posts/urn:li:share:7122658645678465024').to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('li_mentions.json')
    )
    stub_request(:get, 'https://api.linkedin.com/v2/people/(id:yKLJdq-DtT)').to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('li_authors.json')
    )
  end
end
