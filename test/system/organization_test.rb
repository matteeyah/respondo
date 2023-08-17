# frozen_string_literal: true

require 'application_system_test_case'

require 'support/authentication_helper'

class OrganizationTest < ApplicationSystemTestCase
  include AuthenticationHelper

  setup do
    @user = users(:john)
    @organization = organizations(:respondo)

    visit '/'

    sign_in_user(@user)
    sign_in_organization(@organization)
    click_link('Tickets')
  end

  test 'shows the tickets' do
    assert has_text?(tickets(:twitter).content)
    assert has_text?(tickets(:disqus).content)
  end

  test 'allows navigating to tickets' do
    target_ticket = tickets(:twitter)

    within("#ticket_#{target_ticket.id}") do
      page.find(:css, 'i.bi-three-dots').click
      click_link 'View'
    end

    assert has_text?(target_ticket.content)
  end

  test 'allows searching tickets by author name' do
    fill_in 'query', with: "author:#{tickets(:twitter).author.username}"
    click_button :search

    assert has_text?(tickets(:twitter).content)
    assert has_no_text?(tickets(:disqus).content)
  end

  test 'allows searching tickets by content' do
    fill_in 'query', with: "content:#{tickets(:twitter).content}"
    click_button :search

    assert has_text?(tickets(:twitter).content)
    assert has_no_text?(tickets(:disqus).content)
  end

  test 'keeps ticket status context when searching' do
    tickets(:disqus).update!(status: :solved)

    click_link 'Solved'

    # This is a hack to make Capybara wait until the page is loaded after navigating
    find(:xpath, "//input[@type='hidden'][@value='solved']", visible: :hidden)

    fill_in 'query', with: tickets(:disqus).author.username
    click_button :search

    assert has_no_text?(tickets(:twitter).author.username)
    assert has_text?(tickets(:disqus).author.username)
  end
end
