# frozen_string_literal: true

require 'test_helper'

class InternalNotePolicyTest < ActiveSupport::TestCase
  test 'denies access to create? for guests' do
    assert_not_permit InternalNotePolicy, [nil, [brands(:respondo), tickets(:internal_twitter)]], nil, :create
  end

  test 'denies access to edit? for users outside of brand' do
    assert_not_permit InternalNotePolicy, [users(:john), [brands(:respondo), tickets(:internal_twitter)]], nil, :create
  end

  test 'allows access to edit? for users in brand' do
    brands(:respondo).users << users(:john)

    assert_permit InternalNotePolicy, [users(:john), [brands(:respondo), tickets(:internal_twitter)]], nil, :create
  end
end
