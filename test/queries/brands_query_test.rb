# frozen_string_literal: true

require 'test_helper'

class BrandsQueryTest < ActiveSupport::TestCase
  test 'includes screen_name hits' do
    assert_includes BrandsQuery.new(Brand.all, query: 'respondo').call, brands(:respondo)
  end

  test 'does not include screen_name misses' do
    assert_not_includes BrandsQuery.new(Brand.all, query: 'respondo').call, brands(:other)
  end
end
