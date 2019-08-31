# frozen_string_literal: true

module BrandsHelper
  include Pagy::Frontend

  def remove_users_dropdown_options
    @brand.users.pluck(:name, :id)
  end

  def add_users_dropdown_options
    User.not_in_brand(@brand.id).pluck(:name, :id)
  end
end
