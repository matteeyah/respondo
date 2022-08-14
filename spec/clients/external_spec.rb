# frozen_string_literal: true

RSpec.describe Clients::External do
  let(:client) { described_class.new('https://response_url.com', '1234', 'username') }
  let(:response) { instance_double(Net::HTTPResponse, body: 'hello world') }
  let(:client_spy) { instance_spy(Net::HTTP, request: response) }

  before do
    stub_const(Net::HTTP.to_s, class_spy(Net::HTTP, new: client_spy))
  end

  it { expect(client).to be_a_kind_of(Clients::Client) }

  describe '#reply' do
    subject(:reply) { client.reply('responsetext', 'external_uid') }

    let(:post_spy) { instance_spy('Net::HTTP::Post') }

    before do
      stub_const('Net::HTTP::Post', class_spy('Net::HTTP::Post', new: post_spy))
    end

    it 'makes a http request' do
      reply

      expect(client_spy).to have_received(:request).with(post_spy)
    end

    it 'passes parameters with post request' do
      reply

      expect(post_spy).to have_received(:set_form_data).with(
        response_text: 'responsetext',
        parent_id: 'external_uid',
        author: { external_uid: '1234', username: 'username' }
      )
    end

    it 'returns response body' do
      expect(reply).to eq('hello world')
    end
  end

  describe '#delete' do
    subject(:delete) { client.delete }

    let(:delete_spy) { instance_spy('Net::HTTP::Delete') }

    before do
      stub_const('Net::HTTP::Delete', class_spy('Net::HTTP::Delete', new: delete_spy))
    end

    it 'makes a http request' do
      delete

      expect(client_spy).to have_received(:request).with(delete_spy)
    end

    it 'returns response body' do
      expect(delete).to eq('hello world')
    end
  end
end
