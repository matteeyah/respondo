# frozen_string_literal: true

module Brands
  class UserPolicy < ApplicationPolicy
    def create?
      user &&
        record.brand.nil?
    end

    def destroy?
      user &&
        user.brand == record.brand
    end
  end
end
