# frozen_string_literal: true

require 'test_helper'

class TicketPolicyTest < ActiveSupport::TestCase
  test 'denies access to index? for guests' do
    assert_not_permit TicketPolicy, [nil, brands(:respondo)], nil, :index
  end

  test 'denies access to index? for users outside of brand' do
    assert_not_permit TicketPolicy, [users(:john), brands(:respondo)], nil, :index
  end

  test 'allows access to index? for users in brand' do
    brands(:respondo).users << users(:john)

    assert_permit TicketPolicy, [users(:john), brands(:respondo)], nil, :index
  end

  test 'denies access to update? for guests' do
    assert_not_permit TicketPolicy, [nil, brands(:respondo)], tickets(:internal_twitter), :update
  end

  test 'denies access to update? for users outside of brand' do
    assert_not_permit TicketPolicy, [users(:john), brands(:respondo)], tickets(:internal_twitter), :update
  end

  test 'allows access to update? for users in brand' do
    brands(:respondo).users << users(:john)

    assert_permit TicketPolicy, [users(:john), brands(:respondo)], tickets(:internal_twitter), :update
  end

  test 'denies access to destroy? for guests' do
    assert_not_permit TicketPolicy, [nil, brands(:respondo)], tickets(:internal_twitter), :destroy
  end

  test 'denies access to destroy? for users outside of brand' do
    assert_not_permit TicketPolicy, [users(:john), brands(:respondo)], tickets(:internal_twitter), :destroy
  end

  test 'allows access to destroy? for users in brand' do
    brands(:respondo).users << users(:john)

    assert_permit TicketPolicy, [users(:john), brands(:respondo)], tickets(:internal_twitter), :destroy
  end

  test 'denies access to refresh? for guests' do
    assert_not_permit TicketPolicy, [nil, brands(:respondo)], tickets(:internal_twitter), :refresh
  end

  test 'denies access to refresh? for users outside of brand' do
    assert_not_permit TicketPolicy, [users(:john), brands(:respondo)], tickets(:internal_twitter), :refresh
  end

  test 'allows access to refresh? for users in brand' do
    brands(:respondo).users << users(:john)

    assert_permit TicketPolicy, [users(:john), brands(:respondo)], tickets(:internal_twitter), :refresh
  end

  test 'denies access to permalink? for guests' do
    assert_not_permit TicketPolicy, [nil, brands(:respondo)], tickets(:internal_twitter), :permalink
  end

  test 'denies access to permalink? for users outside of brand' do
    assert_not_permit TicketPolicy, [users(:john), brands(:respondo)], tickets(:internal_twitter), :permalink
  end

  test 'allows access to permalink? for users in brand' do
    brands(:respondo).users << users(:john)

    assert_permit TicketPolicy, [users(:john), brands(:respondo)], tickets(:internal_twitter), :permalink
  end
end
