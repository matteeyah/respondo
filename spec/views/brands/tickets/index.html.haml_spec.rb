# frozen_string_literal: true

RSpec.describe 'brands/tickets/index', type: :view do
  let(:brand) { FactoryBot.create(:brand) }
  let(:ticket) { FactoryBot.create(:ticket, status: :open, brand: brand) }
  let(:nested_ticket) { FactoryBot.create(:ticket, brand: brand, parent: ticket, status: :solved) }
  let(:tickets) { { ticket => { nested_ticket => {} } } }

  before do
    assign(:tickets, tickets)

    without_partial_double_verification do
      allow(view).to receive(:brand).and_return(brand)
      allow(view).to receive(:current_user).and_return(FactoryBot.build(:user))
    end

    allow(view).to receive(:user_authorized_for?).and_return(false)
    allow(view).to receive(:user_can_reply_to?).and_return(false)
    allow(view).to receive(:pagy_bootstrap_nav)
  end

  context 'when user is authorized' do
    before do
      allow(view).to receive(:user_authorized_for?).and_return(true)
    end

    it 'renders tickets' do
      expect(render).to include(ticket.content, nested_ticket.content)
    end

    it 'renders ticket status links' do
      expect(render).to have_link('Open Tickets', href: brand_tickets_path(brand, status: 'open'))
        .and have_link('Solved Tickets', href: brand_tickets_path(brand, status: 'solved'))
    end

    it 'renders the refresh button' do
      expect(render).to have_button('↺')
    end
  end

  context 'when user is not authorized' do
    it 'renders tickets' do
      expect(render).to include(ticket.content, nested_ticket.content)
    end

    it 'renders ticket status links' do
      expect(render).to have_link('Open Tickets', href: brand_tickets_path(brand, status: 'open'))
        .and have_link('Solved Tickets', href: brand_tickets_path(brand, status: 'solved'))
    end

    it 'does not render the refresh button' do
      expect(render).not_to have_button('Refresh Tickets')
    end
  end
end
