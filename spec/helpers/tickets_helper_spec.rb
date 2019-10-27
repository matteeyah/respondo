# typed: false
# frozen_string_literal: true

RSpec.describe TicketsHelper, type: :helper do
  describe '#invert_status_action' do
    subject(:invert_status_action) { helper.invert_status_action(status) }

    context 'when status is open' do
      let(:status) { 'open' }

      it { is_expected.to eq('Solve') }
    end

    context 'when status is solved' do
      let(:status) { 'solved' }

      it { is_expected.to eq('Open') }
    end
  end
end
