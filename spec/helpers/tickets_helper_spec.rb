# frozen_string_literal: true

RSpec.describe TicketsHelper, type: :helper do
  describe '#invert_status_action' do
    subject(:invert_status_action) { helper.invert_status_action(status) }

    context 'when status is open' do
      let(:status) { 'open' }

      it { is_expected.to eq(helper.bi_icon('check', 'fs-5')) }
    end

    context 'when status is solved' do
      let(:status) { 'solved' }

      it { is_expected.to eq(helper.bi_icon('folder2-open', 'fs-5')) }
    end
  end

  describe '#invert_status_action_text' do
    subject(:invert_status_action_text) { helper.invert_status_action_text(status) }

    context 'when status is open' do
      let(:status) { 'open' }

      it { is_expected.to eq('Solve') }
    end

    context 'when status is solved' do
      let(:status) { 'solved' }

      it { is_expected.to eq('Open') }
    end
  end

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
        author_link = link_to(ticket.author.username, ticket.author.external_link)
        expect(ticket_author_header).to eq(author_link.to_s)
      end
    end

    context 'when ticket is created from respondo' do
      let(:user_authorized) { true }

      before do
        ticket.creator = create(:user)
      end

      it 'shows local ticket author' do
        author_link = link_to(ticket.author.username, ticket.author.external_link)
        expect(ticket_author_header).to eq("#{ticket.creator.name} as #{author_link}")
      end
    end
  end
end
