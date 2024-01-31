# frozen_string_literal: true

require "test_helper"

class LinkedinTest < ActiveSupport::TestCase
  setup do
    organization_account = organization_accounts(:linkedin)
    mention1 = Mention.create!(external_uid: "li_uid_1", content: "hello 1",
                               author: authors(:pierre), organization: organizations(:respondo),
                               source: organization_accounts(:linkedin),
                               external_link: "https://www.linkedin.com/feed/update/urn:li:share:7122658645678465024")
    Mention.create!(external_uid: "li_uid_2", parent: mention1, content: "hello2",
                    author: authors(:pierre), organization: organizations(:respondo),
                    source: organization_accounts(:linkedin),
                    external_link: "https://www.linkedin.com/feed/update/urn:li:share:7122658645678465024")
    @client = Clients::Linkedin.new("client_id", "client_secret", "token", organization_account)

    stub_request(:get, "https://api.linkedin.com/v2/organizationalEntityAcls?projection=(elements*(organizationalTarget~(id)))&q=roleAssignee&role=ADMINISTRATOR").to_return(
      status: 200, headers: { "Content-Type" => "application/json; charset=utf-8" },
      body: file_fixture("li_admin_organizations.json")
    )
  end

  test "#new_mentions makes a linkedin api request for all posts when a mention identifier is not provided" do
    org_entity_notifications_stub
    li_new_mentions_request = new_mentions_stub
    authors_stub
    @client.new_mentions(nil)

    assert_requested(li_new_mentions_request)
  end

  test "#new_mentions makes a linkedin api request with the since parameter when provided" do
    org_entity_notifications_stub(with_range: true)
    li_new_mentions_request = new_mentions_stub
    authors_stub
    @client.new_mentions(Time.zone.parse("2023-10-24 19:02:33"))

    assert_requested(li_new_mentions_request)
  end

  test "#new_mentions returns an empty array when there are no new mentions" do
    org_entity_notifications_stub(with_range: true, empty: true)
    new_mentions_stub(empty: true)
    authors_stub

    assert_empty @client.new_mentions(Time.zone.parse("2023-10-24 19:02:33"))
  end

  test "#reply makes a linkedin api request" do
    li_reply_request = stub_request(:post, "https://api.linkedin.com/v2/socialActions/urn:li:share:7122658646135619584/comments")
      .with(body: { actor: "urn:li:organization:100702332", object: "7122658646135619584",
                    message: { text: "response" } }.to_json,
            headers: {
              "Accept" => "*/*"
            })
      .and_return(
        status: 200, headers: { "Content-Type" => "application/json; charset=utf-8" },
        body: file_fixture("li_create_comment.json").read
      )

    stub_request(:get, "https://api.linkedin.com/v2/organizations/100702332").to_return(
      status: 200, headers: { "Content-Type" => "application/json; charset=utf-8" },
      body: file_fixture("li_admin_organizations.json")
    )
    @client.reply("response", "7122658646135619584")

    assert_requested(li_reply_request)
  end

  test "#delete makes a linkedin api request" do
    org_entity_notifications_stub
    li_delete_request = stub_request(:delete, "https://api.linkedin.com/v2/socialActions/urn:li:share:7122658645678465024/comments/li_uid_2?actor=urn:li:organization:100702332")
      .and_return(
        status: 200, headers: { "Content-Type" => "application/json; charset=utf-8" },
        body: file_fixture("li_delete_comment.json").read
      )

    @client.delete("li_uid_2")

    assert_requested(li_delete_request)
  end

  def org_entity_notifications_stub(with_range: false, empty: false) # rubocop:disable Metrics/MethodLength
    if with_range
      stub_request(:get, "https://api.linkedin.com/v2/organizationalEntityNotifications?actions=List(SHARE_MENTION)&organizationalEntity=urn:li:organization:100702332&q=criteria&timeRange=(start:1698174154000,end:#{Time.new.to_i}000)").to_return(
        status: 200, headers: { "Content-Type" => "application/json; charset=utf-8" },
        body: file_fixture(empty ? "li_organization_notifications_empty.json" : "li_organization_notifications.json")
      )
    else
      stub_request(:get, "https://api.linkedin.com/v2/organizationalEntityNotifications?actions=List(SHARE_MENTION)&organizationalEntity=urn:li:organization:100702332&q=criteria").to_return(
        status: 200, headers: { "Content-Type" => "application/json; charset=utf-8" },
        body: file_fixture(empty ? "li_organization_notifications_empty.json" : "li_organization_notifications.json")
      )
    end
  end

  def new_mentions_stub(empty: false) # rubocop:disable Metrics/MethodLength
    if empty
      stub_request(:get, "https://api.linkedin.com/v2/posts/urn:li:share:7122658645678465024").and_return(
        status: 200, headers: { "Content-Type" => "application/json; charset=utf-8" },
        body: file_fixture("li_mentions_empty.json").read
      )
    else
      stub_request(:get, "https://api.linkedin.com/v2/posts/urn:li:share:7122658645678465024").and_return(
        status: 200, headers: { "Content-Type" => "application/json; charset=utf-8" },
        body: file_fixture("li_mentions.json").read
      )
    end
  end

  def authors_stub
    stub_request(:get, "https://api.linkedin.com/v2/people/(id:yKLJdq-DtT)").to_return(
      status: 200, headers: { "Content-Type" => "application/json; charset=utf-8" },
      body: file_fixture("li_authors.json")
    )
  end
end
