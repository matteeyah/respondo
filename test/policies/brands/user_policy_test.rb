# frozen_string_literal: true

require 'test_helper'

module Brands
  class UserPolicyTest < ActiveSupport::TestCase
    test 'denies access to create? for guests' do
      assert_not_permit Brands::UserPolicy, [nil, brands(:respondo)], nil, :create
    end

    test 'denies access to create? for users outside of brand' do
      assert_not_permit Brands::UserPolicy, [users(:john), brands(:respondo)], nil, :create
    end

    test 'allows access to create? for users in brand' do
      brands(:respondo).users << users(:john)

      assert_permit Brands::UserPolicy, [users(:john), brands(:respondo)], nil, :create
    end

    test 'denies access to destroy? for guests' do
      assert_not_permit Brands::UserPolicy, [nil, brands(:respondo)], users(:other), :destroy
    end

    test 'denies access to destroy? for users outside of brand' do
      assert_not_permit Brands::UserPolicy, [users(:john), brands(:respondo)], users(:other), :destroy
    end

    test 'allows access to create? if user is in brand' do
      brands(:respondo).users << users(:john)

      assert_permit Brands::UserPolicy, [users(:john), brands(:respondo)], users(:other), :destroy
    end
  end
end
