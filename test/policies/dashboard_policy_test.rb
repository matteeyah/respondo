# frozen_string_literal: true

require 'test_helper'

class DashboardPolicyTest < ActiveSupport::TestCase
  test 'denies access to index? for guests' do
    assert_not_permit DashboardPolicy, nil, brands(:respondo), :index
  end

  test 'denies access to index? for users outside of brand' do
    assert_not_permit DashboardPolicy, users(:john), brands(:respondo), :index
  end

  test 'allows access to index? for users in brand' do
    brands(:respondo).users << users(:john)

    assert_permit DashboardPolicy, users(:john), brands(:respondo), :index
  end
end
