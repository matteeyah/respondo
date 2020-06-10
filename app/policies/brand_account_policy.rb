# frozen_string_literal: true

class BrandAccountPolicy < ApplicationPolicy
  def destroy?
    raise Pundit::NotAuthorizedError, query: :authenticate? unless user

    user.brand == record.brand
  end
end
