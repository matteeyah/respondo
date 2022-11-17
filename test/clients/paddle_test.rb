# frozen_string_literal: true

require 'test_helper'

class PaddleTest < ActiveSupport::TestCase
  test '#change_quantity calls remote Paddle API' do
    client = Clients::Paddle.new('vendor_id', 'vendor_auth_code')
    paddle_request_stub = stub_request(:post, 'https://vendors.paddle.com/api/2.0/subscription/users/update')
      .with(
        body: { 'quantity' => '10', 'subscription_id' => '1', 'vendor_auth_code' => 'vendor_auth_code',
                'vendor_id' => 'vendor_id' }
      ).and_return(status: 200, body: 'hello')

    client.change_quantity(1, 10)

    assert_requested(paddle_request_stub)
  end
end
