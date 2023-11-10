# frozen_string_literal: true

require 'application_system_test_case'

require 'support/authentication_helper'

class OrganizationTest < ApplicationSystemTestCase
  include AuthenticationHelper

  setup do
    @user = users(:john)
    @organization = organizations(:respondo)

    @user.update!(organization: @organization)
    sign_in(@user)

    visit mentions_path
  end

  test 'shows the mentions' do
    assert has_text?(mentions(:x).content)
  end

  test 'allows navigating to mentions' do
    target_mention = mentions(:x)

    within("#mention_#{target_mention.id}") do
      page.find(:css, 'i.bi-three-dots').click
      click_link 'View'
    end

    assert has_text?(target_mention.content)
  end

  test 'allows searching mentions by author name' do
    fill_in 'query', with: "author:#{mentions(:x).author.username}"
    click_button :search

    assert has_text?(mentions(:x).content)
    assert has_no_text?(mentions(:linkedin).content)
  end

  test 'allows searching mentions by content' do
    fill_in 'query', with: "content:#{mentions(:x).content}"
    click_button :search

    assert has_text?(mentions(:x).content)
    assert has_no_text?(mentions(:linkedin).content)
  end

  test 'keeps mention status context when searching' do
    mentions(:linkedin).update!(status: :solved)

    click_link 'Solved'

    # This is a hack to make Capybara wait until the page is loaded after navigating
    find(:xpath, "//input[@type='hidden'][@value='solved']", visible: :hidden)

    fill_in 'query', with: mentions(:linkedin).author.username
    click_button :search

    assert has_no_text?(mentions(:x).author.username)
    assert has_text?(mentions(:linkedin).author.username)
  end
end
