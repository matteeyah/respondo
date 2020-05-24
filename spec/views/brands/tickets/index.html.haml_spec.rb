# frozen_string_literal: true

RSpec.describe 'brands/tickets/index', type: :view do
  let(:brand) { FactoryBot.create(:brand) }
  let(:ticket) { FactoryBot.create(:internal_ticket, status: :open, brand: brand).base_ticket }
  let(:nested_ticket) { FactoryBot.create(:internal_ticket, brand: brand, parent: ticket, status: :solved).base_ticket }
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

    it 'renders ticket search form' do
      expect(render).to have_field('query').and have_button('Search')
    end

    it 'renders the refresh button' do
      within "form[action='#{refresh_brand_tickets_path(ticket.brand)}']" do
        expect(render).to have_button('type="submit"')
      end
    end

    it 'renders the manual ticket info alert' do
      expect(render).to have_text(brand_external_tickets_url(brand, format: :json))
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

    it 'renders ticket search form' do
      expect(render).to have_field('query').and have_button('Search')
    end

    it 'does not render the refresh button' do
      expect(render).not_to have_button('Refresh Tickets')
    end

    it 'does not render the manual ticket info alert' do
      expect(render).not_to have_text(brand_external_tickets_url(brand, format: :json))
    end
  end
end
