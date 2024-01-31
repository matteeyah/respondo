# frozen_string_literal: true

require "test_helper"

class OrganizationsQueryTest < ActiveSupport::TestCase
  test "includes screen_name hits" do
    assert_includes OrganizationsQuery.new(Organization.all, query: "respondo").call, organizations(:respondo)
  end

  test "does not include screen_name misses" do
    assert_not_includes OrganizationsQuery.new(Organization.all, query: "respondo").call, organizations(:other)
  end
end
