# frozen_string_literal: true

RSpec.describe 'brands/tickets/_tickets', type: :view do
  subject(:render_tickets_partial) do
    render partial: 'brands/tickets/tickets', locals: {
      brand: brand, tickets: tickets
    }
  end

  let(:brand) { FactoryBot.create(:brand) }
  let(:user) { FactoryBot.create(:user) }
  let(:ticket) { FactoryBot.create(:internal_ticket, brand: brand, status: :open).base_ticket }
  let(:nested_ticket) { FactoryBot.create(:internal_ticket, brand: brand, parent: ticket, status: :solved).base_ticket }
  let(:tickets) { { ticket => { nested_ticket => {} } } }
  let(:policy_double) { double }

  before do
    FactoryBot.create_list(:internal_note, 2, ticket: ticket)

    without_partial_double_verification do
      allow(view).to receive(:current_user).and_return(user)
      allow(view).to receive(:policy).and_return(policy_double)
    end

    allow(policy_double).to receive_messages(
      refresh?: false, user_in_brand?: false,
      reply?: false, internal_note?: false, invert_status?: false,
      subscription?: false
    )
  end

  it 'displays the tickets' do
    render_tickets_partial

    expect(rendered).to have_text("#{ticket.author.username} - ").and have_text(ticket.content)
      .and have_text("#{nested_ticket.author.username} - ").and have_text(nested_ticket.content)
  end
end
