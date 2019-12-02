# frozen_string_literal: true

RSpec.describe Clients::Disqus do
  let(:client) { described_class.new('api_key', 'api_secret', 'token') }
  let(:posts_spy) { spy }

  let(:disqus_client_spy) do
    class_spy(
      DisqusApi,
      v3: double( # rubocop:disable RSpec/VerifiedDoubles
        users: double( # rubocop:disable RSpec/VerifiedDoubles
          listForums: instance_double(
            DisqusApi::Response, response: ['id' => '12321']
          )
        ), posts: posts_spy
      )
    )
  end

  before do
    stub_const(DisqusApi.to_s, disqus_client_spy)
  end

  it { expect(client).to be_a_kind_of(Clients::Client) }

  describe '#new_mentions' do
    subject(:new_mentions) { client.new_mentions(last_ticket_identifier) }

    context 'when last_ticket_identifier is not specified' do
      let(:last_ticket_identifier) { nil }

      it 'calls the underlying disqus client without since' do
        new_mentions

        expect(posts_spy).to have_received(:list).with(
          api_key: 'api_key', api_secret: 'api_secret', access_token: 'token',
          forum: '12321', order: :asc
        )
      end
    end

    context 'when last_ticket_identifier is specified' do
      let(:last_ticket_identifier) { '12321' }

      it 'calls the underlying twitter client with since' do
        new_mentions

        expect(posts_spy).to have_received(:list).with(
          api_key: 'api_key', api_secret: 'api_secret', access_token: 'token',
          forum: '12321', order: :asc, since: '12321'
        )
      end
    end
  end

  describe '#reply' do
    subject(:reply) { client.reply('response text', 'disqus_uid') }

    it 'calls the underlying twitter client' do
      reply

      expect(posts_spy).to have_received(:create).with(
        api_key: 'api_key', api_secret: 'api_secret', access_token: 'token',
        parent: 'disqus_uid', message: 'response text'
      )
    end
  end
end
