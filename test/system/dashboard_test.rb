# frozen_string_literal: true

require 'application_system_test_case'

require 'support/authentication_helper'

class DashboardTest < ApplicationSystemTestCase
  include AuthenticationHelper

  setup do
    @user = users(:john)
    @organization = organizations(:respondo)

    @user.update!(organization: @organization)
    sign_in(@user)

    visit dashboard_path
  end

  test 'shows the newest tickets' do
    assert has_text?(tickets(:x).content)
  end

  test 'shows the tickets info widgets' do
    assert has_text?('New Tickets')
    assert has_text?('Total Open')
  end

  test 'allows show all tickets with home widget' do
    click_link('New Tickets')

    assert has_text?(tickets(:x).content)
  end
end
