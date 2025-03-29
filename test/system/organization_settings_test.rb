# frozen_string_literal: true

require "application_system_test_case"

require "support/omniauth_helper"
require "support/authentication_helper"

class OrganizationSettingsTest < ApplicationSystemTestCase
  include OmniauthHelper
  include AuthenticationHelper

  setup do
    @user = users(:john)
    @organization = organizations(:respondo)

    @user.update!(organization: @organization)
    sign_in(@user)

    visit settings_path
  end

  test "allows the user to authorize an account" do
    account = Struct.new(:provider, :external_uid, :token, :secret).new(:linkedin, "uid_20")
    add_oauth_mock_for_organization(@organization, account)
    within(page.find("p", text: "Add account").find(:xpath, "./..")) do
      within(page.find(:css, "div.flex.justify-between", text: "LinkedIn")) do
        page.find(:button, "Connect").click
      end
    end

    within(page.find("p", text: "Existing accounts").find(:xpath, "./..")) do
      assert_selector(:css, "div.flex.justify-between", text: "LinkedIn", count: 2)
    end
  end

  test "allows the user to remove an account" do
    within(page.find("p", text: "Existing accounts").find(:xpath, "./..")) do
      within(page.find(:css, "div.flex.justify-between", text: "LinkedIn")) do
        page.find(:link, "Remove").click
      end
    end

    within(page.find("p", text: "Add account").find(:xpath, "./..")) do
      within(page.find(:css, "div.flex.justify-between", text: "LinkedIn")) do
        assert_selector(:button, "Connect")
      end
    end
  end

  test "allows the user to add users to organization" do
    external_user = users(:other)

    visit settings_path
    click_link "Team"

    select external_user.name, from: "add-user"
    click_button "Add"

    within(page.find("span", text: external_user.name).find(:xpath, "../..")) do
      assert_selector(:link, "Remove")
    end
  end

  test "allows the user to remove users from organization" do
    existing_user = users(:other)
    existing_user.update!(organization: @organization)
    visit settings_path

    click_link "Team"

    within(page.find(:css, "div.flex.justify-between", text: existing_user.name)) do
      page.find(:link, "Remove").click
    end

    assert_no_text(existing_user.name)
  end

  test "allows the user to edit the organization domain" do
    click_link "Team"

    fill_in "organization[domain]", with: "example.com"
    click_button "Update"

    assert_field("organization[domain]", with: "example.com")
  end

  test "prevents the user to update the organization with an invalid domain" do
    click_link "Team"

    fill_in "organization[domain]", with: "invalid!domain.com"
    click_button "Update"

    assert_field("organization[domain]", with: "invalid!domain.com")
  end

  test "allows the user to edit the organization ai guidelines" do
    fill_in "organization[ai_guidelines]", with: "Respondo is nice"
    click_button "Update"

    assert_field("organization[ai_guidelines]", with: "Respondo is nice")
  end
end
