# frozen_string_literal: true

RSpec.describe Clients::Twitter do
  let(:client) { described_class.new('api_key', 'api_secret', 'token', 'secret') }
  let(:twitter_client_spy) { instance_spy(Twitter::REST::Client, mentions_timeline: []) }

  before do
    allow(client).to receive(:twitter_client).and_return(twitter_client_spy)
  end

  it { expect(client).to be_a_kind_of(Clients::Client) }

  describe '#new_mentions' do
    subject(:new_mentions) { client.new_mentions(last_ticket_identifier) }

    context 'when last_ticket_identifier is not specified' do
      let(:last_ticket_identifier) { nil }

      it 'calls the underlying twitter client without since_id' do
        new_mentions

        expect(twitter_client_spy).to have_received(:mentions_timeline).with(tweet_mode: 'extended')
      end
    end

    context 'when last_ticket_identifier is specified' do
      let(:last_ticket_identifier) { '12321' }

      it 'calls the underlying twitter client with since_id' do
        new_mentions

        expect(twitter_client_spy).to have_received(:mentions_timeline).with(tweet_mode: 'extended', since_id: last_ticket_identifier)
      end
    end
  end

  describe '#reply' do
    subject(:reply) { client.reply('text', 1) }

    it 'calls the underlying twitter client' do
      reply

      expect(twitter_client_spy).to have_received(:update).with(
        'text', in_reply_to_status_id: 1, auto_populate_reply_metadata: true,
                tweet_mode: 'extended'
      )
    end
  end
end
