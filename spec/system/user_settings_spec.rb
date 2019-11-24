# frozen_string_literal: true

require './spec/support/omniauth_helpers.rb'
require './spec/support/sign_in_out_system_helpers.rb'

RSpec.describe 'User settings', type: :system do
  include OmniauthHelpers
  include SignInOutSystemHelpers

  let(:user) { FactoryBot.create(:user, :with_account) }

  before do
    visit '/'

    sign_in_user(user)

    click_link 'User settings'
  end

  it 'allows the user to authorize an account' do
    add_oauth_mock_for_user(user, FactoryBot.create(:user_account, provider: 'twitter'))
    click_link 'Authorize Twitter'

    expect(page).to have_link('Remove Twitter')
  end

  it 'allows the user to remove an account' do
    FactoryBot.create(:user_account, provider: 'twitter', user: user)
    click_link 'Remove Twitter'

    expect(page).to have_link('Authorize Twitter')
  end

  it 'allows the user to create a personal access token' do
    fill_in :name, with: 'something_nice'
    click_button 'Create'

    expect(page).to have_link('Remove something_nice')
  end

  it 'allows the user to remove a personal access token' do
    FactoryBot.create(:personal_access_token, name: 'something_nice', user: user)

    click_link 'Remove something_nice'

    expect(page).not_to have_link('Remove something_nice')
  end
end
