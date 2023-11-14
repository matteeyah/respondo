# frozen_string_literal: true

require 'test_helper'

require 'support/authentication_request_helper'

class AdsControllerTest < ActionDispatch::IntegrationTest
  include AuthenticationRequestHelper
  include ActiveJob::TestHelper

  setup do
    sign_in(users(:john), user_accounts(:google_oauth2))
    organizations(:respondo).users << users(:john)
  end

  test 'GET new renders the new ad page' do
    get '/ads/new'

    assert_select 'label', 'Product description'
  end

  test 'POST create responds with the loading output' do
    post '/ads', as: :turbo_stream, params: {
      product_description: 'A new product', author_ids: [authors(:james).id]
    }

    assert_turbo_stream(action: :replace, target: 'ad-output')
  end

  test 'POST create schedules the ad creation job' do
    assert_enqueued_jobs 1, only: GenerateAdJob do
      post '/ads', as: :turbo_stream, params: {
        product_description: 'A new product', author_ids: [authors(:james).id]
      }
    end
  end
end
