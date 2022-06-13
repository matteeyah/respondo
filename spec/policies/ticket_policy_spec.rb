# frozen_string_literal: true

RSpec.describe TicketPolicy, type: :policy do
  subject(:ticket_policy) { described_class }

  let(:ticket) { create(:internal_ticket).base_ticket }

  permissions :reply? do
    it 'denies access to guests' do
      expect(ticket_policy).not_to permit(nil, ticket)
    end

    it 'allows access to users in brand' do
      expect(ticket_policy).to permit(create(:user, brand: ticket.brand), ticket)
    end

    it 'allows access to users with client for ticket provider' do
      expect(ticket_policy).to permit(create(:user_account, provider: ticket.provider).user, ticket)
    end
  end

  permissions :internal_note?, :invert_status? do
    it 'denies access to guests' do
      expect(ticket_policy).not_to permit(nil, ticket)
    end

    it 'denies access to users outside of brand' do
      expect(ticket_policy).not_to permit(create(:user), ticket)
    end

    it 'allows access to users in brand' do
      expect(ticket_policy).to permit(create(:user, brand: ticket.brand), ticket)
    end
  end

  permissions :refresh? do
    it 'denies access to guests' do
      expect(ticket_policy).not_to permit(nil, ticket)
    end

    it 'allows all users access' do
      expect(ticket_policy).to permit(create(:user), ticket)
    end
  end
end
