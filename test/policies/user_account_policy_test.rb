# frozen_string_literal: true

require 'test_helper'

class UserAccountPolicyTest < ActiveSupport::TestCase
  test 'denies access to destroy? for guests' do
    assert_not_permit UserAccountPolicy, nil, user_accounts(:google_oauth2), :destroy
  end

  test 'denies access to destroy? for other users' do
    assert_not_permit UserAccountPolicy, users(:other), user_accounts(:google_oauth2), :destroy
  end

  test 'allows access to destroy? for user that owns the account' do
    brands(:respondo).users << users(:john)

    assert_permit UserAccountPolicy, users(:john), user_accounts(:google_oauth2), :destroy
  end
end
