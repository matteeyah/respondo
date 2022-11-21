# frozen_string_literal: true

require 'test_helper'

class BrandAccountPolicyTest < ActiveSupport::TestCase
  test 'denies access to destroy? for guests' do
    assert_not_permit BrandAccountPolicy, [nil, brands(:respondo)], brand_accounts(:twitter), :destroy
  end

  test 'denies access to destroy? for users outside the brand' do
    assert_not_permit BrandAccountPolicy, [users(:john), brands(:respondo)], brand_accounts(:twitter), :destroy
  end

  test 'allows access to destroy? for users in brand' do
    brands(:respondo).users << users(:john)

    assert_permit BrandAccountPolicy, [users(:john), brands(:respondo)], brand_accounts(:twitter), :destroy
  end
end
