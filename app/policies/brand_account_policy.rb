# frozen_string_literal: true

class BrandAccountPolicy < ApplicationPolicy
  def destroy?
    user &&
      user.brand == target_object &&
      user.brand == record.brand
  end
end
