# frozen_string_literal: true

require 'test_helper'

class AssignmentTest < ActiveSupport::TestCase
  test 'validates ticket_id uniqueness' do
    new_assignment = Assignment.new(ticket_id: tickets(:internal_twitter).id, user: users(:john))

    assert_not new_assignment.valid?
  end
end
