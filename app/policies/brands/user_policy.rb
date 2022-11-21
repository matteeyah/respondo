# frozen_string_literal: true

module Brands
  class UserPolicy < ApplicationPolicy
    def create?
      user &&
        user.brand == target_object
    end

    def destroy?
      user &&
        user.brand == target_object
    end
  end
end
