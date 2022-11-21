# frozen_string_literal: true

require 'test_helper'

class UserPolicyTest < ActiveSupport::TestCase
  test 'denies access to edit for guests' do
    assert_not_permit UserPolicy, [nil, nil], users(:john), :edit
  end

  test 'denies access to edit for other users' do
    assert_not_permit UserPolicy, [users(:other), nil], users(:john), :edit
  end

  test 'allows access to edit for self' do
    assert_permit UserPolicy, [users(:john), nil], users(:john), :edit
  end
end
