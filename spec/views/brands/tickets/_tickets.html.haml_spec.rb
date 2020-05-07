# frozen_string_literal: true

RSpec.describe 'brands/tickets/_tickets', type: :view do
  subject(:render_tickets_partial) do
    render partial: 'brands/tickets/tickets', locals: {
      brand: brand, tickets: tickets
    }
  end

  let(:brand) { FactoryBot.create(:brand) }
  let(:user) { FactoryBot.create(:user) }
  let(:ticket) { FactoryBot.create(:ticket, brand: brand, status: :open) }
  let(:nested_ticket) { FactoryBot.create(:ticket, brand: brand, parent: ticket, status: :solved) }
  let(:tickets) { { ticket => { nested_ticket => {} } } }

  before do
    FactoryBot.create_list(:internal_note, 2, ticket: ticket)

    without_partial_double_verification do
      allow(view).to receive(:current_user).and_return(user)
    end

    allow(view).to receive(:user_authorized_for?).and_return(false)
    allow(view).to receive(:user_can_reply_to?).and_return(false)
  end

  it 'displays the tickets' do
    render_tickets_partial

    expect(rendered).to have_text("#{ticket.author.username} - ").and have_text(ticket.content)
      .and have_text("#{nested_ticket.author.username} - ").and have_text(nested_ticket.content)
  end
end
