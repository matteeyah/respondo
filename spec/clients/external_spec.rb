# frozen_string_literal: true

RSpec.describe Clients::External do
  let(:client) { described_class.new('https://response_url.com') }
  let(:net_http_spy) { class_spy(Net::HTTP, post_form: OpenStruct.new(body: nil)) }

  it { expect(client).to be_a_kind_of(Clients::Client) }

  describe '#reply' do
    subject(:reply) { client.reply('response text', 'external_uid') }

    before do
      stub_request(:post, 'https://response_url.com').to_return(status: 200, body: 'hello world')
    end

    it 'calls net http' do
      stub_const(Net::HTTP.to_s, net_http_spy)

      reply

      expect(net_http_spy).to have_received(:post_form).with(
        URI('https://response_url.com'), response_text: 'response text', parent_id: 'external_uid'
      )
    end

    it 'returns response body' do
      expect(reply).to eq('hello world')
    end
  end
end
