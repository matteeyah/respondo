# frozen_string_literal: true

class BrandPolicy < ApplicationPolicy
  def edit?
    raise Pundit::NotAuthorizedError, query: :authenticate? unless user

    record == user.brand
  end

  def update?
    raise Pundit::NotAuthorizedError, query: :authenticate? unless user

    record == user.brand
  end

  def subscription?
    Flipper.enabled?(:skip_subscription_check) ||
      record.subscription&.running?
  end

  def user_in_brand?
    record == user.brand
  end
end
