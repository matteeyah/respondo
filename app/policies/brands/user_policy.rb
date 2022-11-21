# frozen_string_literal: true

module Brands
  class UserPolicy < ApplicationPolicy
    def create?
      user &&
        user.brand == record
    end

    def destroy?
      user &&
        user.brand == record.brand
    end
  end
end
