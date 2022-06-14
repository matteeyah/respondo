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
    click_link 'User settings'

    add_oauth_mock_for_user(user, create(:user_account, provider: 'twitter'))
    click_button 'Authorize Twitter'

    expect(page).to have_link('Remove Twitter')
  end

  it 'allows the user to remove an account' do
    create(:user_account, provider: 'twitter', user:)
    click_link 'User settings'

    click_link 'Remove Twitter'

    expect(page).to have_button('Authorize Twitter')
  end

  it 'allows the user to create a personal access token' do
    click_link 'User settings'

    fill_in :name, with: 'something_nice'
    click_button 'Create'

    expect(page).to have_link('Remove something_nice')
  end

  it 'allows the user to remove a personal access token' do
    create(:personal_access_token, name: 'something_nice', user:)
    click_link 'User settings'

    click_link 'Remove something_nice'

    expect(page).not_to have_link('Remove something_nice')
  end
end
