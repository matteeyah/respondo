# frozen_string_literal: true

require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  test 'validates presence of screen_name' do
    organization = organizations(:respondo)
    organization.screen_name = nil

    assert_predicate organization, :invalid?
  end

  test 'validates format of domain' do
    organization = organizations(:respondo)
    organization.domain = 'invalid!respondohub.com'

    assert_predicate organization, :invalid?
  end

  test 'validates uniqueness of domain' do
    organization = organizations(:respondo)
    organizations(:other).update!(domain: 'respondohub.com')
    organization.domain = 'respondohub.com'

    assert_predicate organization, :invalid?
    assert organization.errors.added?(:domain, :taken, value: 'respondohub.com')
  end

  OrganizationAccount.providers.each_key do |provider_name|
    test "#account_for_provider? returns true when there is an #{provider_name} account" do
      OrganizationAccount.create!(screen_name: 'respondo', external_uid: 'hello_world', provider: provider_name,
                                  organization: organizations(:other))

      assert organizations(:other).account_for_provider?(provider_name)
    end

    test "#account_for_provider? returns false when there is no #{provider_name} account" do
      assert_not organizations(:other).account_for_provider?(provider_name)
    end
  end
end
