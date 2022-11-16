# frozen_string_literal: true

module Clients
  class Paddle
    UPDATE_SUBSCRIPTION_URL = 'https://vendors.paddle.com/api/2.0/subscription/users/update'

    def initialize(vendor_id, vendor_auth_code)
      @vendor_id = vendor_id
      @vendor_auth_code = vendor_auth_code
    end

    def change_quantity(subscription_id, new_quantity)
      Net::HTTP.post_form(
        URI(UPDATE_SUBSCRIPTION_URL),
        vendor_id: @vendor_id,
        vendor_auth_code: @vendor_auth_code,
        subscription_id:,
        quantity: new_quantity
      )
    end
  end
end
