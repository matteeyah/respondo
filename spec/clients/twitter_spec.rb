# typed: false
# frozen_string_literal: true

RSpec.describe Clients::Twitter do
  it { is_expected.to be_an_kind_of(Twitter::REST::Client) }

  describe '#reply' do
    subject(:reply) { client.reply('text', 1) }

    let(:client) { described_class.new }

    before do
      allow(client).to receive(:reply).and_call_original
      allow(client).to receive(:update)
    end

    it 'calls the underlying API' do
      reply

      expect(client).to have_received(:update).with('text', in_reply_to_status_id: 1, auto_populate_reply_metadata: true)
    end
  end
end
