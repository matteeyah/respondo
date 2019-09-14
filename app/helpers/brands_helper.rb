# frozen_string_literal: true

module BrandsHelper
  include Pagy::Frontend

  def add_users_dropdown_options
    User.not_in_brand(@brand.id).pluck(:name, :id)
  end

  def authorized?
    current_brand == @brand
  end
end
