# frozen_string_literal: true

class PersonalAccessTokenPolicy < ApplicationPolicy
  def create?
    user == target_object
  end

  def destroy?
    user == target_object &&
      user == record.user
  end
end
