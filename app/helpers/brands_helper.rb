# frozen_string_literal: true

module BrandsHelper
  include Pagy::Frontend

  def remove_users_dropdown_options
    @brand.users.map { |user| [user.name, user.id] }
  end

  def add_users_dropdown_options
    User.where.not(id: @brand.users.pluck(:id)).map { |user| [user.name, user.id] }
  end
end
