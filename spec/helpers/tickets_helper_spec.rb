# frozen_string_literal: true

RSpec.describe TicketsHelper, type: :helper do
  describe '#invert_status_action' do
    subject(:invert_status_action) { helper.invert_status_action(status) }

    context 'when status is open' do
      let(:status) { 'open' }

      it { is_expected.to eq(helper.bi_icon('check')) }
    end

    context 'when status is solved' do
      let(:status) { 'solved' }

      it { is_expected.to eq(helper.bi_icon('folder2-open')) }
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

  describe '#ticket_header_content' do
    subject(:ticket_header_content) { helper.ticket_header_content(user_authorized, ticket) }

    let(:parent_ticket) { create(:internal_ticket).base_ticket }
    let(:ticket) { create(:internal_ticket, parent: parent_ticket, brand: parent_ticket.brand).base_ticket }
    let(:user_authorized) { false }

    context 'when ticket is root' do
      before do
        ticket.update!(parent: nil)
      end

      it 'shows provider' do
        ticket_link = link_to(ticket.created_at.to_formatted_s(:short), brand_ticket_path(ticket.brand, ticket),
                              'data-turbo' => false)
        expect(ticket_header_content).to eq("#{ticket.author.username} - #{ticket.provider} - #{ticket_link}")
      end
    end

    context 'when ticket is created from respondo' do
      let(:user_authorized) { true }

      before do
        ticket.creator = create(:user)
      end

      it 'shows local ticket author' do
        ticket_link = link_to(ticket.created_at.to_formatted_s(:short), brand_ticket_path(ticket.brand, ticket),
                              'data-turbo' => false)
        expect(ticket_header_content).to eq("#{ticket.creator.name} as #{ticket.author.username} - #{ticket_link}")
      end
    end
  end
end
