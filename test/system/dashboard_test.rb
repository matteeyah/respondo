# frozen_string_literal: true

require 'application_system_test_case'

require 'support/authentication_helper'

class DashboardTest < ApplicationSystemTestCase
  include AuthenticationHelper

  setup do
    @user = users(:john)
    @organization = organizations(:respondo)

    visit '/'

    sign_in_user(@user)
    sign_in_organization(@organization)

    click_link('Dashboard')
  end

  test 'shows the newest tickets' do
    assert has_text?(tickets(:twitter).content)
    assert has_text?(tickets(:disqus).content)
  end

  test 'shows the tickets info widgets' do
    assert has_text?('New Tickets')
    assert has_text?('Total Open')
  end

  test 'allows show all tickets with home widget' do
    click_link('New Tickets')

    assert has_text?(tickets(:twitter).content)
    assert has_text?(tickets(:disqus).content)
  end
end
