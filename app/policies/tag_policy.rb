# frozen_string_literal: true

class TagPolicy < ApplicationPolicy
  def create?
    user &&
      user.brand == record
  end

  def destroy?
    user &&
      user.brand == record.brand
  end
end
