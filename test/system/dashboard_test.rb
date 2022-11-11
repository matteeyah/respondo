# frozen_string_literal: true

require 'application_system_test_case'

require 'sign_in_out_system_helper'

class DashboardTest < ApplicationSystemTestCase
  include SignInOutSystemHelper

  def setup
    @brand = create(:brand, :with_account)
    @tickets = create_list(:internal_ticket, 2, brand: @brand).map(&:base_ticket)
  end

  test 'shows the newest tickets' do
    visit '/'

    sign_in_user
    sign_in_brand(@brand)
    click_link('Dashboard')

    assert has_text?(@tickets.first.content)
    assert has_text?(@tickets.first.author.username)

    assert has_text?(@tickets.second.content)
    assert has_text?(@tickets.second.author.username)
  end

  test 'shows the tickets info widgets' do
    visit '/'

    sign_in_user
    sign_in_brand(@brand)
    click_link('Dashboard')

    assert has_text?('New Tickets')
    assert has_text?(@tickets.count)

    assert has_text?('Total Open')
    assert has_text?(@tickets.count)
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
