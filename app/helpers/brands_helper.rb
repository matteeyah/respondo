# frozen_string_literal: true

module BrandsHelper
  include Pagy::Frontend

  def add_users_dropdown_options_for
    User.where(brand_id: nil).pluck(:id, :name)
  end

  def subscription_badge_class(subscription_status)
    case subscription_status
    when nil, 'deleted'
      'danger'
    when 'past_due'
      'warning'
    when 'trialing', 'active'
      'success'
    end
  end
end
