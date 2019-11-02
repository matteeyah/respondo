# frozen_string_literal: true

RSpec.describe 'Brand settings', type: :system do
  let(:brands) { FactoryBot.create_list(:brand, 2) }

  it 'allows user to navigate to all brands' do
    visit '/'

    click_link 'Brands'

    click_link brands.first.screen_name
    expect(page).to have_text("#{brands.first.screen_name}: Tweets")

    page.go_back

    click_link brands.second.screen_name
    expect(page).to have_text("#{brands.second.screen_name}: Tweets")
  end
end
