# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'validates presence of name' do
    user = users(:other)
    user.name = nil

    assert_predicate user, :invalid?
  end

  UserAccount.providers.each_key do |provider_name|
    test "#account_for_provider? returns true when there is an #{provider_name} account" do
      UserAccount.create!(external_uid: 'hello_world', provider: provider_name, user: users(:other))

      assert users(:other).account_for_provider?(provider_name)
    end

    test "#account_for_provider? returns false when there is no #{provider_name} account" do
      assert_not users(:other).account_for_provider?(provider_name)
    end
  end
end
