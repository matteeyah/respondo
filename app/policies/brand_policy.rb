# frozen_string_literal: true

class BrandPolicy < ApplicationPolicy
  def edit?
    user &&
      user.brand == record
  end

  def update?
    user &&
      user.brand == record
  end
end
