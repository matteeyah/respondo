# frozen_string_literal: true

require 'test_helper'

class MentionTest < ActiveSupport::TestCase
  test 'validates presence of name' do
    product = products(:test_product)
    product.name = nil

    assert_predicate product, :invalid?
  end

  test 'validates presence of description' do
    product = products(:test_product)
    product.description = nil

    assert_predicate product, :invalid?
  end

  test 'validates presence of organization' do
    product = products(:test_product)
    product.organization = nil

    assert_predicate product, :invalid?
  end
end
