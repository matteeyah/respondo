# frozen_string_literal: true

require 'application_system_test_case'

require 'support/authentication_helper'

class DashboardTest < ApplicationSystemTestCase
  include AuthenticationHelper
  include ActiveJob::TestHelper

  setup do
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

    assert_content 'A new product by james_is_cool'
  end
end
