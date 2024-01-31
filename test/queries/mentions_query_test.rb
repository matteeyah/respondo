# frozen_string_literal: true

require "test_helper"

class MentionsQueryTest < ActiveSupport::TestCase
  test "filters by status" do
    query = MentionsQuery.new(Mention.all, status: "solved")
    mentions(:x).update!(status: "solved")

    assert_equal [ mentions(:x) ], query.call
  end

  test "defaults to open status by default" do
    query = MentionsQuery.new(Mention.all, status: "")
    mentions(:linkedin).update!(status: "solved")

    assert_equal [ mentions(:x) ], query.call
  end

  test "filters by assignee" do
    query = MentionsQuery.new(Mention.all, assignee: users(:john).id)

    assert_equal [ mentions(:x) ], query.call
  end

  test "filters by tag" do
    mentions(:x).tags << Tag.create!(name: "hello")
    query = MentionsQuery.new(Mention.all, tag: "hello")

    assert_equal [ mentions(:x) ], query.call
  end

  test "filters by author" do
    query = MentionsQuery.new(Mention.all, author: "james_is_cool")

    assert_equal [ mentions(:x) ], query.call
  end

  test "filters by content" do
    query = MentionsQuery.new(Mention.all, content: "X mention content.")

    assert_equal [ mentions(:x) ], query.call
  end
end
