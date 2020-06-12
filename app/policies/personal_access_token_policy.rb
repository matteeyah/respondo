# frozen_string_literal: true

class PersonalAccessTokenPolicy < ApplicationPolicy
  def create?
    user &&
      user == record.user
  end

  def destroy?
    user &&
      user == record.user
  end
end
