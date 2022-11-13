# frozen_string_literal: true

require 'application_system_test_case'

require 'support/authentication_helper'

class BrandsTest < ApplicationSystemTestCase
  include AuthenticationHelper

  test 'allows the user to navigate to logged in brand tickets' do
    visit '/'

    sign_in_user(users(:john))
    sign_in_brand(brands(:respondo))

    click_link('Tickets')

    assert has_text?('Tickets')
  end
end
