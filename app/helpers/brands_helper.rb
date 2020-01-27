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
    # Twitter::REST::Client implements #blank?
    # This prevents using rails' blank? or present? implementations
    # https://github.com/sferik/twitter/issues/960
    !user&.client_for_provider(provider).nil?
  end

  private

  def users_not_in_brand
    User.where(brand_id: nil)
  end
end
