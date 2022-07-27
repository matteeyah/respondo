# frozen_string_literal: true

RSpec.describe TicketsHelper, type: :helper do
  describe '#ticket_author_header' do
    subject(:ticket_author_header) { helper.ticket_author_header(user_authorized, ticket) }

    let(:parent_ticket) { create(:internal_ticket).base_ticket }
    let(:ticket) { create(:internal_ticket, parent: parent_ticket, brand: parent_ticket.brand).base_ticket }
    let(:user_authorized) { false }

    context 'when ticket is root' do
      before do
        ticket.update!(parent: nil)
      end

      it 'shows provider' do
        author_link = link_to(ticket.author.username, ticket.author.external_link, class: 'text-decoration-none')
        expect(ticket_author_header).to eq(author_link.to_s)
      end
    end

    context 'when ticket is created from respondo' do
      let(:user_authorized) { true }

      before do
        ticket.creator = create(:user)
      end

      it 'shows local ticket author' do
        author_link = link_to(ticket.author.username, ticket.author.external_link, class: 'text-decoration-none')
        expect(ticket_author_header).to eq("#{ticket.creator.name} as #{author_link}")
      end
    end
  end
end
