# frozen_string_literal: true

module BrandsHelper
  include Pagy::Frontend

  def add_users_dropdown_options_for
    users_not_in_brand.pluck(:name, :id)
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

  private

  def users_not_in_brand
    User.where(brand_id: nil)
  end
end
