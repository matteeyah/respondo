# frozen_string_literal: true

RSpec.describe InternalTicket, type: :model do
  describe 'Relations' do
    it { is_expected.to have_one(:base_ticket).dependent(:destroy) }
    it { is_expected.to belong_to(:source) }
  end

  describe '#actual_provider' do
    subject(:actual_provider) { internal_ticket.actual_provider }

    let(:internal_ticket) { create(:internal_ticket) }

    it { is_expected.to eq(internal_ticket.base_ticket.provider) }
  end
end
