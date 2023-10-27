# frozen_string_literal: true

require 'test_helper'

class AssignmentTest < ActiveSupport::TestCase
  test 'validates ticket_id uniqueness' do
    new_assignment = Assignment.new(ticket_id: tickets(:x).id, user: users(:john))

    assert_predicate new_assignment, :invalid?
    assert new_assignment.errors.added?(:ticket_id, :taken, value: tickets(:x).id)
  end
end
