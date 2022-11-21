# frozen_string_literal: true

require 'test_helper'

class ReplyPolicyTest < ActiveSupport::TestCase
  test 'denies access to create? for guests' do
    assert_not_permit ReplyPolicy, [nil, [brands(:respondo), tickets(:internal_twitter)]], nil, :create
  end

  test 'denies access to create? for users outside of brand' do
    assert_not_permit ReplyPolicy, [users(:john), [brands(:respondo), tickets(:internal_twitter)]], nil, :create
  end

  test 'allows access to create? for users in brand' do
    brands(:respondo).users << users(:john)

    assert_permit ReplyPolicy, [users(:john), [brands(:respondo), tickets(:internal_twitter)]], nil, :create
  end
end
