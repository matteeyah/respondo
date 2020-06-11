# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def edit?
    raise Pundit::NotAuthorizedError, query: :authenticate? unless user

    user == record
  end
end
