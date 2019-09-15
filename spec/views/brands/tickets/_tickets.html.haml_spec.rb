# frozen_string_literal: true

RSpec.describe 'brands/tickets/_tickets', type: :view do
  subject(:render_tickets_partial) { render partial: 'brands/tickets/tickets', locals: { brand: brand, tickets: [ticket] } }

  let(:brand) { FactoryBot.create(:brand) }
  let(:ticket) { FactoryBot.create(:ticket, brand: brand, status: :open) }
  let!(:nested_ticket) { FactoryBot.create(:ticket, brand: brand, parent: ticket, status: :solved) }

  before do
    allow(view).to receive(:authorized_for?).and_return(false)
    allow(view).to receive(:user_has_account_for?).and_return(false)
  end

  it 'displays the tickets' do
    render_tickets_partial

    expect(rendered).to have_text "#{ticket.author.username}: #{ticket.content}"
    expect(rendered).to have_text "#{nested_ticket.author.username}: #{nested_ticket.content}"
  end

  context 'when user is authorized' do
    before do
      allow(view).to receive(:authorized_for?).and_return(true)
    end

    it 'displays response forms' do
      render_tickets_partial

      expect(rendered).to have_field(:response_text, count: 2)
      expect(rendered).to have_button('Reply', count: 2)
    end

    it 'displays the status buttons' do
      render_tickets_partial

      expect(rendered).to have_button('Open')
      expect(rendered).to have_button('Solve')
    end
  end

  context 'when user is not authorized' do
    context 'when user does not have account' do
      before do
        allow(view).to receive(:user_has_account_for?).and_return(false)
      end

      it 'does not display response forms' do
        render_tickets_partial

        expect(rendered).not_to have_field(:response_text)
        expect(rendered).not_to have_button('Reply')
      end

      it 'does not display the status button' do
        render_tickets_partial

        expect(rendered).not_to have_button('Open')
        expect(rendered).not_to have_button('Solve')
      end
    end

    context 'when user has account' do
      before do
        allow(view).to receive(:user_has_account_for?).and_return(true)
      end

      it 'displays response forms' do
        render_tickets_partial

        expect(rendered).to have_field(:response_text, count: 2)
        expect(rendered).to have_button('Reply', count: 2)
      end

      it 'does not display the status button' do
        render_tickets_partial

        expect(rendered).not_to have_button('Open')
        expect(rendered).not_to have_button('Solve')
      end
    end
  end
end
