# frozen_string_literal: true

require './spec/support/sign_in_out_system_helpers.rb'

RSpec.describe 'Brands', type: :system do
  include SignInOutSystemHelpers

  let(:brands) { FactoryBot.create_list(:brand, 2) }

  it 'allows user to navigate to all brands' do
    visit '/'

    click_link 'Brands'

    click_link(brands.first.screen_name, wait: 5)
    expect(page).to have_text("#{brands.first.screen_name}: Tickets")

    page.go_back

    click_link brands.second.screen_name
    expect(page).to have_text("#{brands.second.screen_name}: Tickets")
  end

  it 'allows the user to navigate to logged in brand' do
    visit '/'

    FactoryBot.create(:brand_account, brand: brands.first)
    sign_in_user
    sign_in_brand(brands.first)

    click_link 'Current Brand'

    expect(page).to have_text("#{brands.first.screen_name}: Tickets")
  end

  it 'allows searching brands by screen name' do
    visit brands_path

    fill_in :query, with: brands.first.screen_name
    click_button 'Search'

    expect(page).to have_text(brands.first.screen_name)
    expect(page).not_to have_text(brands.second.screen_name)
  end
end
