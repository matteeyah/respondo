# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def edit?
    raise Pundit::NotAuthorizedError, query: :authenticate? unless user

    user == record
  end

  def create?
    raise Pundit::NotAuthorizedError, query: :authenticate? unless user

    record.brand.nil?
  end

  def destroy?
    raise Pundit::NotAuthorizedError, query: :authenticate? unless user

    user.brand == record.brand
  end
end
