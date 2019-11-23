# frozen_string_literal: true

RSpec.describe 'Brands', type: :system do
  let(:brands) { FactoryBot.create_list(:brand, 2) }

  it 'allows user to navigate to all brands' do
    visit '/'

    click_link 'Brands'

    click_link brands.first.screen_name
    expect(page).to have_text("#{brands.first.screen_name}: Tickets")

    page.go_back

    click_link brands.second.screen_name
    expect(page).to have_text("#{brands.second.screen_name}: Tickets")
  end

  it 'allows searching brands by screen name' do
    visit brands_path

    fill_in :query, with: brands.first.screen_name
    click_button 'Search'

    expect(page).to have_text(brands.first.screen_name)
    expect(page).not_to have_text(brands.second.screen_name)
  end
end
