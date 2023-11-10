# frozen_string_literal: true

require 'application_system_test_case'

require 'support/authentication_helper'

class DashboardTest < ApplicationSystemTestCase
  include AuthenticationHelper

  setup do
    @user = users(:john)
    @organization = organizations(:respondo)

    @user.update!(organization: @organization)
    sign_in(@user)

    visit dashboard_path
  end

  test 'shows the newest mentions' do
    assert has_text?(mentions(:x).content)
  end

  test 'shows the mentions info widgets' do
    assert has_text?('New Mentions')
    assert has_text?('Total Open')
  end

  test 'allows show all mentions with home widget' do
    click_link('New Mentions')

    assert has_text?(mentions(:x).content)
  end
end
