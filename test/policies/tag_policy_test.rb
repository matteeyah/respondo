# frozen_string_literal: true

require 'test_helper'

class TagPolicyTest < ActiveSupport::TestCase
  test 'denies access to create? for guests' do
    assert_not_permit TagPolicy, nil, brands(:respondo), :create
  end

  test 'denies access to create? for users outside of brand' do
    assert_not_permit TagPolicy, users(:john), brands(:respondo), :create
  end

  test 'allows access to create? for users in brand' do
    brands(:respondo).users << users(:john)

    assert_permit TagPolicy, users(:john), brands(:respondo), :create
  end

  test 'denies access to destroy? for guests' do
    assert_not_permit TagPolicy, nil, tickets(:internal_twitter), :destroy
  end

  test 'denies access to destroy? for users outside of brand' do
    assert_not_permit TagPolicy, users(:john), tickets(:internal_twitter), :destroy
  end

  test 'allows access to destroy? for users in brand' do
    brands(:respondo).users << users(:john)

    assert_permit TagPolicy, users(:john), tickets(:internal_twitter), :destroy
  end
end
