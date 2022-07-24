# frozen_string_literal: true

require './spec/support/sign_in_out_system_helpers'
require './spec/support/system/allows_interacting_with_tickets_examples'

RSpec.describe 'Ticket', type: :system do
  include SignInOutSystemHelpers

  let(:brand) { create(:brand, :with_account) }
  let!(:ticket) { create(:internal_ticket, source: brand.accounts.first, brand:).base_ticket }

  before do
    create(:subscription, brand:)

    visit '/'
  end

  it 'shows the ticket' do
    user = create(:user, :with_account, brand:)
    sign_in_user(user)
    click_link('Brand Tickets')

    expect(page).to have_text(ticket.content)
    expect(page).to have_text(ticket.author.username)
  end

  include_examples 'allows interacting with tickets' do
    let(:target_ticket) { ticket }
  end
end
