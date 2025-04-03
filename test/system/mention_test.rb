# frozen_string_literal: true

require "application_system_test_case"

require "support/authentication_helper"

class MentionTest < ApplicationSystemTestCase
  include AuthenticationHelper

  setup do
    @user = users(:john)
    @organization = organizations(:respondo)
    @mention = mentions(:x)

    @user.update!(organization: @organization)
    sign_in(@user)
  end

  test "shows the mention" do
    visit mentions_path

    assert_text(@mention.content)
    assert_text(@mention.author.username)
  end

  test "allows navigating to mentions" do
    visit mentions_path
    target_mention = mentions(:x)

    within("#mention_#{target_mention.id}") do
      click_button "mention_#{@mention.id}-menu-button"
      click_link "View"
    end

    assert_text(target_mention.content)
  end

  test "allows searching mentions by author name" do
    visit mentions_path

    fill_in "query", with: "author:#{mentions(:x).author.username}"
    find_field("query").native.send_keys(:return)

    assert_text(mentions(:x).content)
    assert_no_text(mentions(:linkedin).content)
  end

  test "allows searching mentions by content" do
    visit mentions_path

    fill_in "query", with: "content:#{mentions(:x).content}"
    find_field("query").native.send_keys(:return)

    assert_text(mentions(:x).content)
    assert_no_text(mentions(:linkedin).content)
  end

  test "keeps mention status context when searching" do
    visit mentions_path
    mentions(:linkedin).update!(status: :solved)

    click_link "Solved"

    # This is a hack to make Capybara wait until the page is loaded after navigating
    find(:xpath, "//input[@type='hidden'][@value='solved']", visible: :hidden)

    fill_in "query", with: mentions(:linkedin).author.username
    find_field("query").native.send_keys(:return)

    assert_no_text(mentions(:x).author.username)
    assert_text(mentions(:linkedin).author.username)
  end

  test "allows replying to mention" do
    visit mentions_path

    account = @mention.source
    account.update!(token: "hello", secret: "world")

    response_text = "Hello from Respondo system tests"
    stub_x_reply_response(
      account.external_uid,
      @organization.screen_name,
      @mention.external_uid,
      response_text
    )

    within("#mention_#{@mention.id}") do
      fill_in "mention[content]", with: response_text
      click_button "mention_#{@mention.id}-reply-button"
    end

    assert_text("#{@user.name} as @#{@organization.screen_name}")
    assert_text(response_text)
  end

  test "allows asking the AI to answer" do
    visit mentions_path

    stub_request(:post, "https://api.openai.com/v1/responses")
      .to_return(
        status: 200, body: file_fixture("openai_response.json"),
        headers: { "Content-Type" => "application/json" }
      )

    within("#mention_#{@mention.id}") do
      click_link href: "/mentions/#{@mention.id}.turbo_stream"

      assert_text("In a peaceful grove beneath a silver moon")
    end
  end

  test "allows asking the AI to answer with a prompt" do
    visit mentions_path

    stub_request(:post, "https://api.openai.com/v1/responses")
      .to_return(
        status: 200, body: file_fixture("openai_response.json"),
        headers: { "Content-Type" => "application/json" }
      )

    within("#mention_#{@mention.id}") do
      fill_in "mention[content]", with: "I am amazing!"
      click_link href: "/mentions/#{@mention.id}.turbo_stream"

      assert_text("In a peaceful grove beneath a silver moon")
    end
  end

  test "allows leaving internal notes on mentions" do
    visit mentions_path

    internal_note_text = "Internal note from Respondo system tests."

    within("#mention_#{@mention.id}") do
      click_link "1"

      fill_in "internal_note[content]", with: internal_note_text
      click_button "Create Note"
    end

    within("#mention_#{@mention.id}_internal_notes") do
      assert_text(@user.name)
      assert_text(internal_note_text)
    end
  end

  test "allows solving mentions" do
    visit mentions_path

    within("#mention_#{@mention.id}") do
      select "solved", from: "mention-status"
    end

    click_link "Solved"

    assert_text(@mention.author.username)
    assert_text(@mention.content)
  end

  test "allows adding mention tags" do
    visit mentions_path

    within("#mention_#{@mention.id}") do
      fill_in :'tag[name]', with: "hello\n"
    end

    within("#mention_#{@mention.id}") do
      assert_selector(:css, "span", text: "hello")
    end
  end

  test "allows removing mention tags" do
    first_tag = Tag.create!(name: "first_tag")
    @mention.tags << [ first_tag, Tag.create!(name: "second_tag") ]
    visit mentions_path

    within("#mention_#{@mention.id}") do
      within("span", text: "first_tag") do
        click_link href: "/mentions/#{@mention.id}/tags/#{first_tag.id}"
      end
    end

    within("#mention_#{@mention.id}") do
      assert_no_selector(:css, "span", text: "first_tag")
      assert_selector(:css, "span", text: "second_tag")
    end
  end

  test "allows updating mention assignment" do
    visit mentions_path

    within("#mention_#{@mention.id}") do
      select @user.name, from: "mention-assignment"
    end

    assert_text(@user.name)
  end

  test "allows deleting mentions" do
    @mention.update!(creator: @user)
    @mention.source.update!(token: "hello", secret: "world")
    visit mentions_path

    stub_request(:delete, "https://api.twitter.com/2/tweets/uid_1")
      .and_return(
        status: 200, headers: { "Content-Type" => "application/json; charset=utf-8" },
        body: file_fixture("x_delete_tweet.json").read
      )

    within("#mention_#{@mention.id}") do
      click_button "mention_#{@mention.id}-menu-button"
      click_link "Delete"
    end

    assert_no_text(@mention.content)
  end

  test "allows navigating to mentions externally" do
    @mention.source.update!(token: "hello", secret: "world")
    visit mentions_path

    within("#mention_#{@mention.id}") do
      click_button "mention_#{@mention.id}-menu-button"

      assert_link "External View"
    end
  end

  private

  def stub_x_reply_response(user_external_uid, user_screen_name, in_reply_to_status_id, response_text) # rubocop:disable Metrics/MethodLength
    stub_request(:get, "https://api.twitter.com/2/tweets/1445880548472328192?expansions=author_id,referenced_tweets.id&tweet.fields=created_at").and_return(
      status: 200, headers: { "Content-Type" => "application/json; charset=utf-8" },
      body: {
        data: {
          id: 123_456, text: response_text, created_at: Time.zone.now, author_id: user_external_uid,
          referenced_tweets: [ { type: "replied_to", id: in_reply_to_status_id } ]
        },
        includes: { users: [ { id: user_external_uid, username: user_screen_name } ] }
      }.to_json
    )
    stub_request(:post, "https://api.twitter.com/2/tweets")
      .with(body: { text: response_text, reply: { in_reply_to_tweet_id: in_reply_to_status_id } }.to_json)
      .and_return(
        status: 200, headers: { "Content-Type" => "application/json; charset=utf-8" },
        body: file_fixture("x_create_tweet.json").read
      )
  end
end
