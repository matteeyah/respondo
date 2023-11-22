# frozen_string_literal: true

require 'application_system_test_case'

require 'support/authentication_helper'

class DashboardTest < ApplicationSystemTestCase
  include AuthenticationHelper
  include ActiveJob::TestHelper

  setup do
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

    @user = users(:john)
    @organization = organizations(:respondo)

    @user.update!(organization: @organization)
    sign_in(@user)
  end

  test 'creates an ad with parameters' do
    visit new_ad_path

    fill_in :product_description, with: 'A new product'
    select 'james_is_cool', from: :author_ids
    click_button 'Save'

    sleep 1 # Wait for job to enqueue
    perform_enqueued_jobs(only: GenerateAdJob)

    assert_content 'You are amazing!'
  end
end
