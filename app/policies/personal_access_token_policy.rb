# frozen_string_literal: true

class PersonalAccessTokenPolicy < ApplicationPolicy
  def create?
    raise Pundit::NotAuthorizedError, query: :authenticate? unless user

    user == record.user
  end

  def destroy?
    raise Pundit::NotAuthorizedError, query: :authenticate? unless user

    user == record.user
  end
end
