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
    Flipper.enabled?(:disable_subscriptions) ||
      record.subscription&.running?
  end

  def user_in_brand?
    user &&
      record == user.brand
  end
end
