# frozen_string_literal: true

RSpec.describe ExternalTicket, type: :model do
  describe 'Validations' do
    subject(:external_ticket) { create(:external_ticket) }

    it { is_expected.to validate_presence_of(:response_url) }
  end

  describe 'Relations' do
    it { is_expected.to have_one(:base_ticket).dependent(:destroy) }
  end

  describe '#actual_provider' do
    subject(:actual_provider) { external_ticket.actual_provider }

    let(:external_ticket) { create(:external_ticket) }

    context 'when ticket has custom provider' do
      before do
        external_ticket.update!(custom_provider: 'hacker_news')
      end

      it { is_expected.to eq('hacker_news') }
    end

    context 'when ticket does not have custom provider' do
      it { is_expected.to eq('external') }
    end
  end
end
