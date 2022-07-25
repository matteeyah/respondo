# frozen_string_literal: true

RSpec.describe InternalTicket, type: :model do
  describe 'Relations' do
    it { is_expected.to have_one(:base_ticket).dependent(:destroy) }
    it { is_expected.to belong_to(:source) }
  end

  describe '#provider' do
    subject(:provider) { internal_ticket.provider }

    let(:internal_ticket) { create(:internal_ticket) }

    it { is_expected.to eq(internal_ticket.source.provider) }
  end
end
