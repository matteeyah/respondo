# frozen_string_literal: true

class TagPolicy < ApplicationPolicy
  def create?
    user &&
      user.brand == target_object.first &&
      target_object.first == target_object.second.brand
  end

  def destroy?
    user &&
      user.brand == target_object.first &&
      target_object.first == target_object.second.brand
  end
end
