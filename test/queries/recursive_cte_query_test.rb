# frozen_string_literal: true

require 'test_helper'

class RecursiveCteQueryTest < ActiveSupport::TestCase
  test 'returns self and all descendants' do
    child = Mention.create!(
      external_uid: 'uid_10', parent: mentions(:x), content: 'hello',
      author: authors(:james), organization: organizations(:respondo),
      source: organization_accounts(:x),
      external_link: 'https://x.com/twitter/status/uid_1'
    )
    nested_child = Mention.create!(
      external_uid: 'uid_20', status: :open, content: 'Lorem', parent: child,
      author: authors(:james), organization: organizations(:respondo),
      source: organization_accounts(:x),
      external_link: 'https://x.com/twitter/status/uid_1'
    )
    query = RecursiveCteQuery.new(Mention.all, model_column: :parent_id, recursive_cte_column: :id)

    assert_equal [mentions(:x), mentions(:linkedin), child, nested_child], query.call
  end
end
