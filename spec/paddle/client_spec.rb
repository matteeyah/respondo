# frozen_string_literal: true

RSpec.describe Paddle::Client do
  let(:client) { described_class.new('vendor_id', 'vendor_auth_code') }
  let(:net_http_spy) { class_spy(Net::HTTP, post_form: OpenStruct.new(body: nil)) }

  describe '#change_quantity' do
    subject(:change_quantity) { client.change_quantity(1, 10) }

    it 'calls net http' do
      stub_const(Net::HTTP.to_s, net_http_spy)

      change_quantity

      expect(net_http_spy).to have_received(:post_form)
        .with(URI(Paddle::Client::UPDATE_SUBSCRIPTION_URL),
              vendor_id: 'vendor_id', vendor_auth_code: 'vendor_auth_code', subscription_id: 1, quantity: 10)
    end
  end
end
