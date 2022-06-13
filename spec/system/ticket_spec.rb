# frozen_string_literal: true

require './spec/support/sign_in_out_system_helpers'
require './spec/support/system/allows_interacting_with_tickets_examples'

RSpec.describe 'Ticket', type: :system do
  include SignInOutSystemHelpers

  let(:brand) { create(:brand, :with_account) }
  let(:ticket) { create(:internal_ticket, brand:).base_ticket }

  before do
    create(:subscription, brand:)

    visit brand_ticket_path(ticket.brand, ticket)
  end

  it 'shows the ticket' do
    expect(page).to have_text(ticket.content)
    expect(page).to have_text(ticket.author.username)
  end

  include_examples 'allows interacting with tickets' do
    let(:target_ticket) { ticket }
  end
end
