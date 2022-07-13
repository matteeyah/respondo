# frozen_string_literal: true

require './spec/support/omniauth_helpers'
require './spec/support/sign_in_out_system_helpers'

RSpec.describe 'User settings', type: :system do
  include OmniauthHelpers
  include SignInOutSystemHelpers

  let(:user) { create(:user, :with_account) }

  before do
    visit '/'

    sign_in_user(user)
  end

  it 'allows the user to authorize an account' do
    find('#settings').click
    click_link 'User settings'

    add_oauth_mock_for_user(user, create(:user_account, provider: 'activedirectory'))
    within(page.find(:css, 'div.list-group-item', text: 'Azure Active Directory')) do
      page.find(:css, 'i.bi-plus-lg').click
    end

    expect(page).to have_selector(:css, 'i.bi-trash3-fill')
  end

  it 'allows the user to remove an account' do
    create(:user_account, provider: 'activedirectory', user:)
    find('#settings').click
    click_link 'User settings'

    within(page.find('h6', text: 'Existing accounts').find(:xpath, '..')) do
      within(page.find(:css, 'div.list-group-item', text: 'Azure Active Directory')) do
        page.find(:css, 'i.bi-trash3-fill').click
      end
    end

    within(page.find(:css, 'div.list-group-item', text: 'Azure Active Directory')) do
      expect(page).to have_selector(:css, 'i.bi-plus-lg')
    end
  end

  it 'allows the user to create a personal access token' do
    find('#settings').click
    click_link 'User settings'

    fill_in :name, with: 'something_nice'
    click_button 'Create'

    within(page.find('h6', text: 'Existing personal access tokens').find(:xpath, '..')) do
      expect(page).to have_selector(:css, 'i.bi-trash3-fill')
    end
  end

  it 'allows the user to remove a personal access token' do
    create(:personal_access_token, name: 'something_nice', user:)
    find('#settings').click
    click_link 'User settings'

    within(page.find('h6', text: 'Existing personal access tokens').find(:xpath, '..')) do
      page.find(:css, 'i.bi-trash3-fill').click
    end

    expect(page).not_to have_text('something_nice')
  end
end
