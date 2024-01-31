# frozen_string_literal: true

require "test_helper"

class MentionsHelperTest < ActionView::TestCase
  test "#mention_author_header shows provider when mention is root" do
    parent_mention = mentions(:x)
    mention = Mention.create!(
      external_uid: "hello_world", status: :open, content: "Lorem ipsum dolor sit amet",
      parent: parent_mention, author: authors(:james), organization: organizations(:respondo),
      source: organization_accounts(:x),
      external_link: "https://x.com/twitter/status/uid_1"
    )
    author_link = link_to("@#{mention.author.username}", mention.author.external_link, class: "text-decoration-none")

    assert_equal author_link, mention_author_header(mention)
  end

  test "#mention_author_header shows local author when mention is from respondo" do
    mention = mentions(:x)
    mention.update!(creator: users(:john))
    author_link = link_to("@#{mention.author.username}", mention.author.external_link, class: "text-decoration-none")

    assert_equal "#{mention.creator.name} as #{author_link}", mention_author_header(mention)
  end
end
