# frozen_string_literal: true

require 'test_helper'

class LinkedinTest < ActiveSupport::TestCase
  test '#new_mentions makes a linkedin api request for all posts when a ticket identifier is not provided' do
    client = Clients::Linkedin.new('client_id', 'client_secret', 'token')

    stub_request(:get, 'https://api.linkedin.com/v2/organizationalEntityAcls?projection=(elements*(organizationalTarget~(id)))&q=roleAssignee&role=ADMINISTRATOR').to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('li_admin_organizations.json')
    )
    stub_request(:get, 'https://api.linkedin.com/v2/organizationalEntityNotifications?actions=List(SHARE_MENTION)&organizationalEntity=urn:li:organization:100702332&q=criteria').to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('li_organization_notifications.json')
    )
    li_new_mentions_request = stub_request(:get, 'https://api.linkedin.com/v2/posts/urn:li:share:7122658645678465024').and_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('li_mentions.json').read
    )
    stub_request(:get, 'https://api.linkedin.com/v2/people/(id:yKLJdq-DtT)').to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('li_authors.json')
    )

    client.new_mentions(nil)

    assert_requested(li_new_mentions_request)
  end

  test '#new_mentions makes a linkedin api request with the since parameter when provided' do
    client = Clients::Linkedin.new('client_id', 'client_secret', 'token')

    stub_request(:get, 'https://api.linkedin.com/v2/organizationalEntityAcls?projection=(elements*(organizationalTarget~(id)))&q=roleAssignee&role=ADMINISTRATOR').to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('li_admin_organizations.json')
    )
    stub_request(:get, "https://api.linkedin.com/v2/organizationalEntityNotifications?actions=List(SHARE_MENTION)&organizationalEntity=urn:li:organization:100702332&q=criteria&timeRange=(start:1698174154000,end:#{Time.new.to_i}000)").to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('li_organization_notifications.json')
    )
    li_new_mentions_request = stub_request(:get, 'https://api.linkedin.com/v2/posts/urn:li:share:7122658645678465024').and_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('li_mentions.json').read
    )
    stub_request(:get, 'https://api.linkedin.com/v2/people/(id:yKLJdq-DtT)').to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('li_authors.json')
    )

    client.new_mentions(Time.zone.parse('2023-10-24 19:02:33'))

    assert_requested(li_new_mentions_request)
  end

  test '#new_mentions returns an empty array when there are no new mentions' do
    client = Clients::Linkedin.new('client_id', 'client_secret', 'token')

    stub_request(:get, 'https://api.linkedin.com/v2/organizationalEntityAcls?projection=(elements*(organizationalTarget~(id)))&q=roleAssignee&role=ADMINISTRATOR').to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('li_admin_organizations.json')
    )
    stub_request(:get, "https://api.linkedin.com/v2/organizationalEntityNotifications?actions=List(SHARE_MENTION)&organizationalEntity=urn:li:organization:100702332&q=criteria&timeRange=(start:1698174154000,end:#{Time.new.to_i}000)").to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('li_organization_notifications_empty.json')
    )
    stub_request(:get, 'https://api.linkedin.com/v2/posts/urn:li:share:7122658645678465024')
      .and_return(
        status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
        body: file_fixture('li_mentions_empty.json').read
      )
    stub_request(:get, 'https://api.linkedin.com/v2/people/(id:yKLJdq-DtT)').to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('li_authors.json')
    )

    assert_empty client.new_mentions(Time.zone.parse('2023-10-24 19:02:33'))
  end

  test '#reply makes a linkedin api request' do # rubocop:disable Metrics/BlockLength
    client = Clients::Linkedin.new('client_id', 'client_secret', 'token')

    stub_request(:get, 'https://api.linkedin.com/v2/organizationalEntityAcls?projection=(elements*(organizationalTarget~(id)))&q=roleAssignee&role=ADMINISTRATOR').to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('li_admin_organizations.json')
    )

    li_reply_request = stub_request(:post, 'https://api.linkedin.com/v2/socialActions/urn:li:share:7122658646135619584/comments')
      .with(body: { actor: 'urn:li:organization:100702332', object: '7122658646135619584',
                    message: { text: 'response' } }.to_json,
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization' => 'Bearer token',
              'Content-Type' => 'application/json',
              'Host' => 'api.linkedin.com',
              'Linkedin-Version' => '202311',
              'User-Agent' => 'Ruby'
            })
      .and_return(
        status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
        body: file_fixture('li_create_comment.json').read
      )

    stub_request(:get, 'https://api.linkedin.com/v2/organizations/100702332').to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('li_admin_organizations.json')
    )

    client.reply('response', '7122658646135619584')

    assert_requested(li_reply_request)
  end

  test '#delete makes a linkedin api request' do
    client = Clients::Linkedin.new('client_id', 'client_secret', 'token')

    stub_request(:get, 'https://api.linkedin.com/v2/organizationalEntityAcls?projection=(elements*(organizationalTarget~(id)))&q=roleAssignee&role=ADMINISTRATOR').to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('li_admin_organizations.json')
    )
    stub_request(:get, 'https://api.linkedin.com/v2/organizationalEntityNotifications?actions=List(SHARE_MENTION)&organizationalEntity=urn:li:organization:100702332&q=criteria').to_return(
      status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: file_fixture('li_organization_notifications.json')
    )
    li_delete_request = stub_request(:delete, 'https://api.linkedin.com/v2/socialActions/urn:li:share:7122658645678465024/comments/1?actor=urn:li:organization:100702332 ')
      .and_return(
        status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
        body: file_fixture('li_delete_comment.json').read
      )

    client.delete('1')

    assert_requested(li_delete_request)
  end

  test '#permalink generates a linkedin url' do
    client = Clients::Linkedin.new('client_id', 'client_secret', 'token')

    assert_equal 'https://www.linkedin.com/feed/update/urn:li:share:7122658645678465024', client.permalink('https://www.linkedin.com/feed/update/urn:li:share:7122658645678465024')
  end
end
