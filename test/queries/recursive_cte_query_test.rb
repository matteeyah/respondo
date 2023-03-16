# frozen_string_literal: true

require 'test_helper'

class RecursiveCteQueryTest < ActiveSupport::TestCase
  test 'returns self and all descendants' do
    child = Ticket.create!(
      external_uid: 'uid_10', parent: tickets(:twitter), content: 'hello',
      author: authors(:james), organization: organizations(:respondo), ticketable: internal_tickets(:twitter)
    )
    nested_child = Ticket.create!(
      external_uid: 'uid_20', status: :open, content: 'Lorem', parent: child,
      author: authors(:james), organization: organizations(:respondo), ticketable: internal_tickets(:twitter)
    )
    query = RecursiveCteQuery.new(Ticket.all, model_column: :parent_id, recursive_cte_column: :id)

    assert_equal [tickets(:twitter), tickets(:disqus), tickets(:external), child, nested_child],
                 query.call
  end
end
