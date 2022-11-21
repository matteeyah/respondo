# frozen_string_literal: true

require 'test_helper'

class AssignmentPolicyTest < ActiveSupport::TestCase
  test 'denies access to create? for guests' do
    assert_not_permit AssignmentPolicy, nil, brands(:respondo), :create
  end

  test 'denies access to create? for users outside of brand' do
    assert_not_permit AssignmentPolicy, users(:john), brands(:respondo), :create
  end

  test 'allows access to create? for users in brand' do
    brands(:respondo).users << users(:john)

    assert_permit AssignmentPolicy, users(:john), brands(:respondo), :create
  end
end
