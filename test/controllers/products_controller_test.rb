# frozen_string_literal: true

require 'test_helper'

require 'support/authentication_request_helper'

class ProductsControllerTest < ActionDispatch::IntegrationTest
  include AuthenticationRequestHelper
  include ActiveJob::TestHelper

  setup do
    sign_in(users(:john), user_accounts(:google_oauth2))
    organizations(:respondo).users << users(:john)
  end

  test 'GET list of all organization products' do
    get '/products'

    assert_select 'span', 'Products'
  end

  test 'GET new renders the new product page' do
    get '/products/new'

    assert_select 'label', 'Description'
  end

  test 'POST create product redirects to products root' do
    post '/products',
         params: { product: { name: 'Test', description: 'Test description', organization: organizations(:respondo) } }

    assert_redirected_to products_path
  end

  test 'GET edit product with content' do
    get "/products/#{products(:quick_glow).id}/edit"

    assert_select 'label', 'Description'
  end

  test 'POST update product redirects to products root' do
    patch "/products/#{products(:quick_glow).id}",
          params: { product: { name: 'Test update', description: 'Test description update',
                               organization: organizations(:respondo) } }

    assert_redirected_to products_path
  end

  test 'DELETE product redirects to products root' do
    assert_changes -> { Product.count }, from: 1, to: 0 do
      delete "/products/#{products(:quick_glow).id}", xhr: true
    end
  end
end
