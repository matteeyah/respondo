# frozen_string_literal: true

require 'test_helper'

class MentionTest < ActiveSupport::TestCase
  test 'validates presence of name' do
    product = products(:quick_glow)
    product.name = nil

    assert_predicate product, :invalid?
  end

  test 'validates presence of description' do
    product = products(:quick_glow)
    product.description = nil

    assert_predicate product, :invalid?
  end

  test 'validates presence of organization' do
    product = products(:quick_glow)
    product.organization = nil

    assert_predicate product, :invalid?
  end
end
