# frozen_string_literal: true

class UserAccountPolicy < ApplicationPolicy
  def destroy?
    raise Pundit::NotAuthorizedError, query: :authenticate? unless user

    user == record.user
  end
end
