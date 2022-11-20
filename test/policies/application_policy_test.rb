# frozen_string_literal: true

require 'test_helper'

class ApplicationPolicyTest < ActiveSupport::TestCase
  test 'denies access to index? for all users' do
    assert_not_permit ApplicationPolicy, users(:john), nil, :index
  end

  test 'denies access to show? for all users' do
    assert_not_permit ApplicationPolicy, users(:john), nil, :show
  end

  test 'denies access to create? for all users' do
    assert_not_permit ApplicationPolicy, users(:john), nil, :create
  end

  test 'denies access to update? for all users' do
    assert_not_permit ApplicationPolicy, users(:john), nil, :update
  end

  test 'denies access to edit? for all users' do
    assert_not_permit ApplicationPolicy, users(:john), nil, :edit
  end

  test 'denies access to destroy? for all users' do
    assert_not_permit ApplicationPolicy, users(:john), nil, :destroy
  end

  test 'resolves scope to whole relation' do
    scope = ApplicationPolicy::Scope.new(users(:john), Ticket.all)

    assert_equal Ticket.all, scope.resolve
  end
end
