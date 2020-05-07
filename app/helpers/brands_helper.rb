# frozen_string_literal: true

module BrandsHelper
  include Pagy::Frontend

  def add_users_dropdown_options_for
    users_not_in_brand.pluck(:name, :id)
  end

  def user_authorized_for?(user, brand)
    user&.brand == brand
  end

  def user_can_reply_to?(user, provider)
    return true if provider == 'external'

    user&.client_for_provider(provider).present?
  end

  def subscription_badge_class(subscription_status)
    case subscription_status
    when nil, 'deleted'
      'danger'
    when 'trialing'
      'warning'
    when 'active'
      'success'
    end
  end

  private

  def users_not_in_brand
    User.where(brand_id: nil)
  end
end
