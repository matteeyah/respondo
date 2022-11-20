# frozen_string_literal: true

require 'test_helper'

module Brands
  class UserPolicyTest < ActiveSupport::TestCase
    test 'denies access to create? for guests' do
      assert_not_permit Brands::UserPolicy, nil, users(:other), :create
    end

    test 'denies access to create? if external user already has brand' do
      brands(:respondo).users << users(:other)

      assert_not_permit Brands::UserPolicy, users(:john), users(:other), :create
    end

    test 'allows access to create? if external user does not have brand' do
      assert_permit Brands::UserPolicy, users(:john), users(:other), :create
    end

    test 'denies access to destroy? for guests' do
      assert_not_permit Brands::UserPolicy, nil, users(:other), :destroy
    end

    test 'denies access to destroy? if user is outside of brand' do
      brands(:respondo).users << users(:john)

      assert_not_permit Brands::UserPolicy, users(:john), users(:other), :destroy
    end

    test 'allows access to create? if user is in brand' do
      brands(:respondo).users << users(:other)
      brands(:respondo).users << users(:john)

      assert_permit Brands::UserPolicy, users(:john), users(:other), :destroy
    end
  end
end
