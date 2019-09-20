# frozen_string_literal: true

module BrandsHelper
  include Pagy::Frontend

  def add_users_dropdown_options
    User.where.not(brand_id: current_brand.id).or(User.where(brand_id: nil)).pluck(:name, :id)
  end

  def authorized_for?(brand)
    current_brand == brand
  end

  def user_can_reply_to?(user, provider)
    # Twitter::REST::Client implements #blank?
    # This prevents using rails' blank? or present? implementations
    # https://github.com/sferik/twitter/issues/960
    !user.client_for_provider(provider).nil?
  end
end
