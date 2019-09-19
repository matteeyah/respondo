# frozen_string_literal: true

module BrandsHelper
  include Pagy::Frontend

  def add_users_dropdown_options
    User.where.not(brand_id: current_brand.id).or(User.where(brand_id: nil)).pluck(:name, :id)
  end

  def authorized_for?(brand)
    current_brand == brand
  end

  def user_has_account_for?(provider)
    current_user&.accounts&.exists?(provider: provider)
  end
end
