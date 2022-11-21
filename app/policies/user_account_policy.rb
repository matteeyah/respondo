# frozen_string_literal: true

class UserAccountPolicy < ApplicationPolicy
  def destroy?
    user == target_object &&
      user == record.user
  end
end
