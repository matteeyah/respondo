# frozen_string_literal: true

require 'test_helper'

class RecursiveCteQueryTest < ActiveSupport::TestCase
  test 'returns self and all descendants' do
    child = Ticket.create!(
      external_uid: 'uid_10', parent: tickets(:x), content: 'hello',
      author: authors(:james), organization: organizations(:respondo), ticketable: internal_tickets(:x)
    )
    nested_child = Ticket.create!(
      external_uid: 'uid_20', status: :open, content: 'Lorem', parent: child,
      author: authors(:james), organization: organizations(:respondo), ticketable: internal_tickets(:x)
    )
    query = RecursiveCteQuery.new(Ticket.all, model_column: :parent_id, recursive_cte_column: :id)

    assert_equal [tickets(:x), tickets(:external), tickets(:email), child, nested_child],
                 query.call
  end
end
