# frozen_string_literal: true

require 'test_helper'

require 'support/authentication_request_helper'

module Organizations
  class OrganizationAccountsControllerTest < ActionDispatch::IntegrationTest
    include AuthenticationRequestHelper

    test 'DELETE destroy when the user is authorized redirects the user to edit page' do
      sign_in(users(:john), user_accounts(:google_oauth2))
      organizations(:respondo).users << users(:john)

      delete "/organization/organization_accounts/#{organization_accounts(:twitter).id}"

      assert_redirected_to settings_path
    end

    test 'DELETE destroy when the user is not authorized redirects the user to root path' do
      sign_in(users(:john), user_accounts(:google_oauth2))

      delete "/organization/organization_accounts/#{organization_accounts(:twitter).id}"

      assert_redirected_to root_path
    end

    test 'DELETE destroy when the user is not signed in redirects the user to login path' do
      delete "/organization/organization_accounts/#{organization_accounts(:twitter).id}"

      assert_redirected_to login_path
    end
  end
end
