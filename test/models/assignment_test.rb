require 'test_helper'

class AssignmentTest < ActiveSupport::TestCase
  test 'validates ticket_id uniqueness' do
    existing_assignment = create(:assignment)

    new_assignment = build(:assignment, ticket_id: existing_assignment.ticket_id)

    assert_not new_assignment.save
  end
end
