# frozen_string_literal: true

class AssignmentPolicy < ApplicationPolicy
  def create?
    user &&
      user.brand == record
  end
end
