# frozen_string_literal: true

require './spec/support/sign_in_out_system_helpers'

RSpec.describe 'Brands', type: :system do
  include SignInOutSystemHelpers

  let!(:brands) { create_list(:brand, 2) }

  it 'allows the user to navigate to logged in brand tickets' do
    visit '/'

    create(:brand_account, brand: brands.first)
    sign_in_user
    sign_in_brand(brands.first)

    click_link 'Tickets'

    expect(page).to have_text("Tickets (#{brands.first.screen_name})")
  end
end
