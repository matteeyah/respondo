# frozen_string_literal: true

require 'test_helper'

class TicketPolicyTest < ActiveSupport::TestCase
  test 'denies access to index? for guests' do
    assert_not_permit TicketPolicy, nil, brands(:respondo), :index
  end

  test 'denies access to index? for users outside of brand' do
    assert_not_permit TicketPolicy, users(:john), brands(:respondo), :index
  end

  test 'allows access to index? for users in brand' do
    brands(:respondo).users << users(:john)

    assert_permit TicketPolicy, users(:john), brands(:respondo), :index
  end

  test 'denies access to update? for guests' do
    assert_not_permit TicketPolicy, nil, tickets(:internal_twitter), :update
  end

  test 'denies access to update? for users outside of brand' do
    assert_not_permit TicketPolicy, users(:john), tickets(:internal_twitter), :update
  end

  test 'allows access to update? for users in brand' do
    brands(:respondo).users << users(:john)

    assert_permit TicketPolicy, users(:john), tickets(:internal_twitter), :update
  end

  test 'denies access to destroy? for guests' do
    assert_not_permit TicketPolicy, nil, tickets(:internal_twitter), :destroy
  end

  test 'denies access to destroy? for users outside of brand' do
    assert_not_permit TicketPolicy, users(:john), tickets(:internal_twitter), :destroy
  end

  test 'allows access to destroy? for users in brand' do
    brands(:respondo).users << users(:john)

    assert_permit TicketPolicy, users(:john), tickets(:internal_twitter), :destroy
  end

  test 'denies access to reply? for guests' do
    assert_not_permit TicketPolicy, nil, tickets(:internal_twitter), :reply
  end

  test 'denies access to reply? for users outside of brand' do
    assert_not_permit TicketPolicy, users(:john), tickets(:internal_twitter), :reply
  end

  test 'allows access to reply? for users in brand' do
    brands(:respondo).users << users(:john)

    assert_permit TicketPolicy, users(:john), tickets(:internal_twitter), :reply
  end

  test 'denies access to internal_note? for guests' do
    assert_not_permit TicketPolicy, nil, tickets(:internal_twitter), :internal_note
  end

  test 'denies access to internal_note? for users outside of brand' do
    assert_not_permit TicketPolicy, users(:john), tickets(:internal_twitter), :internal_note
  end

  test 'allows access to internal_note? for users in brand' do
    brands(:respondo).users << users(:john)

    assert_permit TicketPolicy, users(:john), tickets(:internal_twitter), :internal_note
  end

  test 'denies access to refresh? for guests' do
    assert_not_permit TicketPolicy, nil, tickets(:internal_twitter), :refresh
  end

  test 'denies access to refresh? for users outside of brand' do
    assert_not_permit TicketPolicy, users(:john), tickets(:internal_twitter), :refresh
  end

  test 'allows access to refresh? for users in brand' do
    brands(:respondo).users << users(:john)

    assert_permit TicketPolicy, users(:john), tickets(:internal_twitter), :refresh
  end

  test 'denies access to permalink? for guests' do
    assert_not_permit TicketPolicy, nil, tickets(:internal_twitter), :permalink
  end

  test 'denies access to permalink? for users outside of brand' do
    assert_not_permit TicketPolicy, users(:john), tickets(:internal_twitter), :permalink
  end

  test 'allows access to permalink? for users in brand' do
    brands(:respondo).users << users(:john)

    assert_permit TicketPolicy, users(:john), tickets(:internal_twitter), :permalink
  end
end
