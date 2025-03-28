# frozen_string_literal: true

require "test_helper"

class OrganizationsHelperTest < ActionView::TestCase
  test "#add_users_dropdown_options_for returns users outside of organization" do
    users(:john).update!(organization: organizations(:respondo))

    assert_equal [ [ users(:other).id, users(:other).name ] ], add_users_dropdown_options_for
  end
end
