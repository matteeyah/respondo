# frozen_string_literal: true

require 'test_helper'

class OrganizationsHelperTest < ActionView::TestCase
  test '#add_users_dropdown_options_for returns users outside of organization' do
    users(:john).update!(organization: organizations(:respondo))

    assert_equal [[users(:other).id, users(:other).name]], add_users_dropdown_options_for
  end

  [[nil, 'danger'], %w[deleted danger], %w[past_due warning], %w[trialing success],
   %w[active success]].each do |status_pair|
     test "#subscription_badge_class returns #{status_pair.second} when subscription is #{status_pair.first}" do
       assert_equal status_pair.second, subscription_badge_class(status_pair.first)
     end
   end
end
