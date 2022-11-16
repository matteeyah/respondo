# frozen_string_literal: true

require 'test_helper'

class PersonalAccessTokenTest < ActiveSupport::TestCase
  test 'validates presence of name' do
    token = personal_access_tokens(:default)
    token.name = nil

    assert_predicate token, :invalid?
  end

  test 'validates uniqueness of name' do
    token = personal_access_tokens(:default).dup

    assert_predicate token, :invalid?
    assert token.errors.added?(:name, :taken, value: 'PERSONAL_ACCESS_TOKEN_1')
  end
end
