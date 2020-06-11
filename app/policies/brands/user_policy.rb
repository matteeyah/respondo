# frozen_string_literal: true

module Brands
  class UserPolicy < ApplicationPolicy
    def create?
      raise Pundit::NotAuthorizedError, query: :authenticate? unless user

      record.brand.nil?
    end

    def destroy?
      raise Pundit::NotAuthorizedError, query: :authenticate? unless user

      user.brand == record.brand
    end
  end
end
