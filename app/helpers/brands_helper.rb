# frozen_string_literal: true

module BrandsHelper
  include Pagy::Frontend

  def add_users_dropdown_options
    User.not_in_brand(current_brand.id).pluck(:name, :id)
  end

  def authorized_for?(brand)
    current_brand == brand
  end

  def user_has_account_for?(provider)
    current_user&.accounts&.exists?(provider: provider)
  end
end
