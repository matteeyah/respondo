# frozen_string_literal: true

class BrandPolicy < ApplicationPolicy
  def edit?
    user &&
      record == user.brand
  end

  def update?
    user &&
      record == user.brand
  end

  def subscription?
    record.subscription&.running?
  end
end
