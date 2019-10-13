# frozen_string_literal: true

RSpec.describe 'brands/tickets/index', type: :view do
  let(:brand) { FactoryBot.create(:brand) }
  let!(:ticket) { FactoryBot.create(:ticket, status: :open, brand: brand) }

  before do
    assign(:tickets, brand.tickets.root.with_descendants_hash)

    without_partial_double_verification do
      allow(view).to receive(:brand).and_return(brand)
      allow(view).to receive(:current_user).and_return(FactoryBot.build(:user))
    end

    allow(view).to receive(:user_authorized_for?).and_return(false)
    allow(view).to receive(:user_can_reply_to?).and_return(false)
    allow(view).to receive(:pagy_bootstrap_nav)
  end

  it 'renders tickets' do
    expect(render).to include(ticket.content)
  end

  it 'renders ticket status links' do
    expect(render).to have_link('Open Tickets', href: brand_tickets_path(brand, status: 'open'))
      .and have_link('Solved Tickets', href: brand_tickets_path(brand, status: 'solved'))
  end

  context 'when user is authorized' do
    before do
      allow(view).to receive(:user_authorized_for?).and_return(true)
    end

    it 'renders the refresh button' do
      expect(render).to have_button('Refresh Tickets')
    end
  end

  context 'when user is not authorized' do
    it 'does not render the refresh button' do
      expect(render).not_to have_button('Refresh Tickets')
    end
  end
end
