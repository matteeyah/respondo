# frozen_string_literal: true

require 'test_helper'

class BrandsHelperTest < ActionView::TestCase
  test '#add_users_dropdown_options_for returns users outside of brand' do
    first_brand = create(:brand)
    create(:user, brand: first_brand)
    second_brand = create(:brand)
    create(:user, brand: second_brand)

    user_without_brand = create(:user)

    assert_equal [[user_without_brand.id, user_without_brand.name]], add_users_dropdown_options_for
  end

  [[nil, 'danger'], %w[deleted danger], %w[past_due warning], %w[trialing success],
   %w[active success]].each do |status_pair|
     test "#subscription_badge_class returns #{status_pair.second} when subscription is #{status_pair.first}" do
       assert_equal status_pair.second, subscription_badge_class(status_pair.first)
     end
   end
end
