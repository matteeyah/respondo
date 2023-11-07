# frozen_string_literal: true

require 'test_helper'

class ExternalTest < ActiveSupport::TestCase
  test '#reply makes an external post request' do
    client = Clients::External.new('https://respondohub.com/')

    external_reply_request = stub_request(:post, 'https://respondohub.com/')
      .with(
        body: { 'parent_id' => 'external_uid', 'response_text' => 'response' }
      ).and_return(status: 200, body: '{ "hello": "world" }')

    assert_equal({ hello: 'world' }, client.reply('response', 'external_uid'))
    assert_requested(external_reply_request)
  end

  test '#delete makes an external delete request' do
    client = Clients::External.new('https://respondohub.com/')

    external_delete_request = stub_request(:delete, 'https://respondohub.com/')
      .and_return(status: 200, body: '{ "hello": "world" }')

    assert_equal({ hello: 'world' }, client.delete('external_uid'))
    assert_requested(external_delete_request)
  end
end
