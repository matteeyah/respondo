# frozen_string_literal: true

require 'application_system_test_case'

require 'support/omniauth_helper'

class HomepageTest < ApplicationSystemTestCase
  include AuthenticationHelper

  setup do
    @user = users(:john)
    @organization = organizations(:respondo)

    @user.update!(organization: @organization)
    sign_in(@user)

    visit products_path
  end

  test 'shows the products' do
    assert has_text?(products(:quick_glow).name)
  end

  test 'allows navigating to product' do
    target_product = products(:quick_glow)

    within(page.find('h5', text: target_product.name).find(:xpath, '..')) do
      page.find(:button, 'Edit').click
    end

    assert has_text?(target_product.name)
  end
end
