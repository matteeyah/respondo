# frozen_string_literal: true

require 'application_system_test_case'

require 'sign_in_out_system_helper'

class BrandsTest < ApplicationSystemTestCase
  include SignInOutSystemHelper

  def setup
    @brands = create_list(:brand, 2)
  end

  test 'allows the user to navigate to logged in brand tickets' do
    visit '/'

    create(:brand_account, brand: @brands.first, provider: 'twitter')
    sign_in_user
    sign_in_brand(@brands.first)

    click_link('Brand Tickets')

    assert has_text?('Tickets')
  end
end
