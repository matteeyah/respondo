# frozen_string_literal: true

RSpec.describe 'brands/tickets/_tickets', type: :view do
  subject(:render_tickets_partial) do
    render partial: 'brands/tickets/tickets', locals: {
      brand: brand, tickets: brand.tickets.root.with_descendants_hash
    }
  end

  let(:brand) { FactoryBot.create(:brand) }
  let(:ticket) { FactoryBot.create(:ticket, brand: brand, status: :open) }
  let!(:nested_ticket) { FactoryBot.create(:ticket, brand: brand, parent: ticket, status: :solved) }

  before do
    without_partial_double_verification do
      allow(view).to receive(:current_user).and_return(FactoryBot.build(:user))
    end

    allow(view).to receive(:user_authorized_for?).and_return(false)
    allow(view).to receive(:user_can_reply_to?).and_return(false)
  end

  it 'displays the tickets' do
    render_tickets_partial

    expect(rendered).to have_text("#{ticket.author.username}: #{ticket.content}")
      .and have_text("#{nested_ticket.author.username}: #{nested_ticket.content}")
  end

  context 'when user is authorized' do
    before do
      allow(view).to receive(:user_authorized_for?).and_return(true)
    end

    it 'displays response forms' do
      render_tickets_partial

      expect(rendered).to have_field(:response_text, count: 2).and have_button('Reply', count: 2)
    end

    it 'displays the status buttons' do
      render_tickets_partial

      expect(rendered).to have_button('Open').and have_button('Solve')
    end
  end

  context 'when user is not authorized' do
    context 'when user does not have account' do
      before do
        allow(view).to receive(:user_can_reply_to?).and_return(false)
      end

      it 'does not display response textbox' do
        render_tickets_partial

        expect(rendered).not_to have_field(:response_text)
      end

      it 'does not display response button' do
        render_tickets_partial

        expect(rendered).not_to have_button('Reply')
      end

      it 'does not display open buttons' do
        render_tickets_partial

        expect(rendered).not_to have_button('Open')
      end

      it 'does not display solve buttons' do
        render_tickets_partial

        expect(rendered).not_to have_button('Solve')
      end
    end

    context 'when user has account' do
      before do
        allow(view).to receive(:user_can_reply_to?).and_return(true)
      end

      it 'displays response forms' do
        render_tickets_partial

        expect(rendered).to have_field(:response_text, count: 2).and have_button('Reply', count: 2)
      end

      it 'does not display open buttons' do
        render_tickets_partial

        expect(rendered).not_to have_button('Open')
      end

      it 'does not display solve buttons' do
        render_tickets_partial

        expect(rendered).not_to have_button('Solve')
      end
    end
  end
end
