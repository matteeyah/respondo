# frozen_string_literal: true

require 'test_helper'

class UserPolicyTest < ActiveSupport::TestCase
  test 'denies access to edit for guests' do
    assert_not_permit UserPolicy, nil, users(:john), :edit
  end

  test 'denies access to edit for other users' do
    assert_not_permit UserPolicy, users(:other), users(:john), :edit
  end

  test 'allows access to edit for self' do
    assert_permit UserPolicy, users(:john), users(:john), :edit
  end
end
