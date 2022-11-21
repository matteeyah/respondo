# frozen_string_literal: true

class AssignmentPolicy < ApplicationPolicy
  def create?
    user &&
      user.brand == target_object.first &&
      target_object.first == target_object.second.brand
  end
end
