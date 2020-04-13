# frozen_string_literal: true

RSpec.describe TicketsHelper, type: :helper do
  describe '#invert_status_action' do
    subject(:invert_status_action) { helper.invert_status_action(status) }

    context 'when status is open' do
      let(:status) { 'open' }

      it { is_expected.to eq(helper.fa_icon('check')) }
    end

    context 'when status is solved' do
      let(:status) { 'solved' }

      it { is_expected.to eq(helper.fa_icon('folder-open')) }
    end
  end

  describe '#ticket_header_content' do
    subject(:ticket_header_content) { helper.ticket_header_content(user_authorized, ticket, ticket.brand) }

    let(:parent_ticket) { FactoryBot.create(:ticket) }
    let(:ticket) { FactoryBot.create(:ticket, parent: parent_ticket, brand: parent_ticket.brand) }
    let(:user_authorized) { false }

    context 'when ticket is root' do
      before do
        ticket.update(parent: nil)
      end

      it 'shows provider' do
        ticket_link = link_to(ticket.created_at.to_formatted_s(:short), brand_ticket_path(ticket.brand, ticket))
        expect(ticket_header_content).to eq("#{ticket.author.username} - #{ticket.provider} - #{ticket_link}")
      end
    end

    context 'when ticket is created from respondo' do
      let(:user_authorized) { true }

      before do
        ticket.user = FactoryBot.create(:user)
      end

      it 'shows local ticket author' do
        ticket_link = link_to(ticket.created_at.to_formatted_s(:short), brand_ticket_path(ticket.brand, ticket))
        expect(ticket_header_content).to eq("#{ticket.user.name} as #{ticket.author.username} - #{ticket_link}")
      end
    end
  end
end
