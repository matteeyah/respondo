# frozen_string_literal: true

require 'test_helper'

class AssignmentTest < ActiveSupport::TestCase
  test 'validates mention_id uniqueness' do
    new_assignment = Assignment.new(mention_id: mentions(:x).id, user: users(:john))

    assert_predicate new_assignment, :invalid?
    assert new_assignment.errors.added?(:mention_id, :taken, value: mentions(:x).id)
  end
end
