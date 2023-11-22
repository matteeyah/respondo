# frozen_string_literal: true

require 'test_helper'

class GenerateAdJobTest < ActiveJob::TestCase
  include Turbo::Broadcastable::TestHelper

  setup do
    @guid = SecureRandom.uuid

    stub_request(:get, 'https://api.twitter.com/2/users/uid_1/tweets')
      .to_return(
        status: 200, headers: { 'Content-Type' => 'application/json; charset=utf-8' },
        body: file_fixture('x_posts.json').read
      )

    stub_request(:post, 'https://api.openai.com/v1/chat/completions')
      .to_return(
        status: 200, body: file_fixture('openai_chat.json'),
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  test 'broadcasts ad output' do
    assert_turbo_stream_broadcasts([@guid, :ad], count: 1) do
      GenerateAdJob.perform_now(@guid, 'Analyze the results.', authors(:james))
    end
  end
end
