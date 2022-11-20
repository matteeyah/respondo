# frozen_string_literal: true

require 'test_helper'

class PersonalAccessTokenPolicyTest < ActiveSupport::TestCase
  test 'denies access to create? for guests' do
    assert_not_permit PersonalAccessTokenPolicy, nil, personal_access_tokens(:default), :create
  end

  test 'denies access to create? for other users' do
    assert_not_permit PersonalAccessTokenPolicy, users(:other), personal_access_tokens(:default), :create
  end

  test 'allows access to create? for user that owns the token' do
    assert_permit PersonalAccessTokenPolicy, users(:john), personal_access_tokens(:default), :create
  end

  test 'denies access to destroy? for guests' do
    assert_not_permit PersonalAccessTokenPolicy, nil, personal_access_tokens(:default), :destroy
  end

  test 'denies access to destroy? for other users' do
    assert_not_permit PersonalAccessTokenPolicy, users(:other), personal_access_tokens(:default), :destroy
  end

  test 'allows access to destroy? for user that owns the token' do
    assert_permit PersonalAccessTokenPolicy, users(:john), personal_access_tokens(:default), :destroy
  end
end
