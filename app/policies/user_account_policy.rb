# frozen_string_literal: true

class UserAccountPolicy < ApplicationPolicy
  def destroy?
    user &&
      user == record.user
  end
end
