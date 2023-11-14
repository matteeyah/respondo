# frozen_string_literal: true

require 'test_helper'

class GenerateAdJobTest < ActiveJob::TestCase
  include Turbo::Broadcastable::TestHelper

  setup do
    @guid = SecureRandom.uuid
  end

  test 'broadcasts ad output' do
    assert_turbo_stream_broadcasts([@guid, :ad], count: 1) do
      GenerateAdJob.perform_now(@guid, 'Analyze the results.', authors(:james))
    end
  end
end
