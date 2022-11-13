# frozen_string_literal: true

require 'application_system_test_case'

require 'support/authentication_helper'

class DashboardTest < ApplicationSystemTestCase
  include AuthenticationHelper

  def setup
    @brand = brands(:respondo)
    @tickets = tickets(:internal_twitter, :internal_disqus)
  end

  test 'shows the newest tickets' do
    visit '/'

    sign_in_user
    sign_in_brand(@brand)
    click_link('Dashboard')

    assert has_text?(@tickets.first.content)
    assert has_text?(@tickets.second.content)
  end

  test 'shows the tickets info widgets' do
    visit '/'

    sign_in_user
    sign_in_brand(@brand)
    click_link('Dashboard')

    assert has_text?('New Tickets')
    assert has_text?('Total Open')
  end

  test 'allows show all tickets with home widget' do
    visit '/'

    sign_in_user
    sign_in_brand(@brand)
    click_link('Dashboard')

    click_link('New Tickets')

    assert has_text?(@tickets.first.content)
    assert has_text?(@tickets.second.content)
  end
end
