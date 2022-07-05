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
    page.find(:css, "form[action='/auth/activedirectory?state=user']").click

    expect(page).to have_selector(:css, "a[href='#{user_user_account_path(user, user.accounts.last)}'")
  end

  it 'allows the user to remove an account' do
    target_account = create(:user_account, provider: 'activedirectory', user:)
    find('#settings').click
    click_link 'User settings'

    page.find(:css, "a[href='/users/1/user_accounts/#{target_account.id}']").click

    expect(page).to have_selector("form[action='/auth/activedirectory?state=user']")
  end

  it 'allows the user to create a personal access token' do
    find('#settings').click
    click_link 'User settings'

    fill_in :name, with: 'something_nice'
    click_button 'Create'

    expect(page).to have_selector(:css, "a[href='#{user_personal_access_token_path(user, '1')}']")
  end

  it 'allows the user to remove a personal access token' do
    pat = create(:personal_access_token, name: 'something_nice', user:)
    find('#settings').click
    click_link 'User settings'

    page.find(:css, "a[href='#{user_personal_access_token_path(user, pat)}']").click

    expect(page).not_to have_text('something_nice')
  end
end
