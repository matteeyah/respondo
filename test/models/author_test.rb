# frozen_string_literal: true

require "test_helper"

class AuthorTest < ActiveSupport::TestCase
  test "validates presence of external_uid" do
    author = authors(:james)
    author.external_uid = nil

    assert_predicate author, :invalid?
  end

  test "validates presence of username" do
    author = authors(:james)
    author.username = nil

    assert_predicate author, :invalid?
  end

  test "validates presence of provider" do
    author = authors(:james)
    author.provider = nil

    assert_predicate author, :invalid?
  end

  test "validates uniqueness of external_uid scoped to provider" do
    author = authors(:james).dup

    assert_predicate author, :invalid?
    assert author.errors.added?(:external_uid, :taken, value: "uid_1")
  end

  test ".from_client! returns an author" do
    author_hash = { external_uid: "1", username: "hello", external_link: "https://external.com/james_is_cool" }

    assert_instance_of Author, Author.from_client!(author_hash, :twitter, organizations(:respondo))
  end

  test ".from_client! creates an author when it does not exist" do
    author_hash = { external_uid: "1", username: "hello", external_link: "https://external.com/james_is_cool" }

    assert_difference -> { Author.count }, 1 do
      Author.from_client!(author_hash, :twitter, organizations(:respondo))
    end
  end

  test ".from_client! finds an author when it exists" do
    author_hash = { external_uid: "uid_1", username: "helloworld", external_link: "https://external.com/james_is_cool" }

    assert_no_difference -> { Author.count } do
      Author.from_client!(author_hash, :twitter, organizations(:respondo))
    end
  end

  test ".from_client! updates username" do
    author_hash = { external_uid: "uid_1", username: "helloworld", external_link: "https://external.com/james_is_cool" }

    assert_changes -> { authors(:james).reload.username }, from: "james_is_cool", to: "helloworld" do
      Author.from_client!(author_hash, :twitter, organizations(:respondo))
    end
  end

  test "#external_link creates link for twitter author" do
    author = authors(:james)

    assert_equal "https://x.com/james_is_cool", author.external_link
  end
end
