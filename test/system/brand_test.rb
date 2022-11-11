# frozen_string_literal: true

require 'application_system_test_case'

require 'sign_in_out_system_helper'

class BrandTest < ApplicationSystemTestCase
  include SignInOutSystemHelper

  def setup
    @brand = create(:brand, :with_account)
    @tickets = create_list(:internal_ticket, 2, brand: @brand, source: @brand.accounts.first).map(&:base_ticket)
    create(:subscription, brand: @brand)

    visit '/'
  end

  test 'shows the tickets' do
    user = create(:user, :with_account, brand: @brand)
    sign_in_user(user)
    click_link('Tickets')

    assert has_text?(@tickets.first.content)
    assert has_text?(@tickets.first.author.username)

    assert has_text?(@tickets.second.content)
    assert has_text?(@tickets.second.author.username)
  end

  test 'allows navigating to tickets' do
    sign_in_user
    sign_in_brand(@brand)
    click_link('Tickets')

    target_ticket = @tickets.first

    within("#ticket_#{target_ticket.id}") do
      page.find(:css, 'i.bi-bullseye').click
    end

    assert has_text?(target_ticket.content)
  end

  test 'allows searching tickets by author name' do
    sign_in_user
    sign_in_brand(@brand)
    click_link('Tickets')

    fill_in 'query', with: @tickets.first.author.username
    click_button :search

    assert has_text?(@tickets.first.content)
    assert_not has_text?(@tickets.second.content)
  end

  test 'allows searching tickets by content' do
    sign_in_user
    sign_in_brand(@brand)
    click_link('Tickets')

    fill_in 'query', with: @tickets.first.content
    click_button :search

    assert has_text?(@tickets.first.content)
    assert_not has_text?(@tickets.second.content)
  end

  test 'keeps ticket status context when searching' do
    solved_tickets = create_list(:internal_ticket, 2, status: :solved, brand: @brand).map(&:base_ticket)
    @tickets.first.update!(content: solved_tickets.first.content)

    sign_in_user
    sign_in_brand(@brand)
    click_link('Tickets')

    click_link 'Solved'

    # This is a hack to make Capybara wait until the page is loaded after navigating
    find(:xpath, "//input[@type='hidden'][@value='solved']", visible: :hidden)

    fill_in 'query', with: solved_tickets.first.content
    click_button :search

    assert has_text?(solved_tickets.first.author.username)
    assert_not has_text?(solved_tickets.second.author.username)
    assert_not has_text?(@tickets.first.author.username)
    assert_not has_text?(@tickets.second.author.username)
  end

  test 'allows searching by nested ticket content' do
    nested_ticket = create(:internal_ticket, brand: @brand, parent: @tickets.first).base_ticket
    nested_nested_ticket = create(:internal_ticket, brand: @brand, parent: nested_ticket).base_ticket

    sign_in_user
    sign_in_brand(@brand)
    click_link('Tickets')

    fill_in 'query', with: nested_ticket.content
    click_button :search

    assert has_text?(nested_ticket.content)
    assert has_text?(nested_nested_ticket.content)
    assert_not has_text?(@tickets.first.content)
    assert_not has_text?(@tickets.second.content)
  end
end
