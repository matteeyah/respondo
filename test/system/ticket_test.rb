# frozen_string_literal: true

require 'application_system_test_case'

require 'sign_in_out_system_helper'

class TicketTest < ApplicationSystemTestCase
  include SignInOutSystemHelper

  def setup
    @brand = create(:brand, :with_account)
    @ticket = create(:internal_ticket, source: @brand.accounts.first, brand: @brand).base_ticket
    create(:subscription, brand: @brand)

    visit '/'
  end

  test 'shows the ticket' do
    user = create(:user, :with_account, brand: @brand)
    sign_in_user(user)
    click_link('Tickets')

    assert has_text?(@ticket.content)
    assert has_text?(@ticket.author.username)
  end
end
