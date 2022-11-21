# frozen_string_literal: true

require 'test_helper'

class BrandPolicyTest < ActiveSupport::TestCase
  test 'denies access to edit? for guests' do
    assert_not_permit BrandPolicy, [nil, nil], brands(:respondo), :edit
  end

  test 'denies access to edit? for users outside of brand' do
    assert_not_permit BrandPolicy, [users(:john), nil], brands(:respondo), :edit
  end

  test 'allows access to edit? for users in brand' do
    brands(:respondo).users << users(:john)

    assert_permit BrandPolicy, [users(:john), nil], brands(:respondo), :edit
  end

  test 'denies access to update? for guests' do
    assert_not_permit BrandPolicy, [nil, nil], brands(:respondo), :update
  end

  test 'denies access to update? for users outside of brand' do
    assert_not_permit BrandPolicy, [users(:john), nil], brands(:respondo), :update
  end

  test 'allows access to update? for users in brand' do
    brands(:respondo).users << users(:john)

    assert_permit BrandPolicy, [users(:john), nil], brands(:respondo), :update
  end
end
