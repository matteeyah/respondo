# frozen_string_literal: true

class TicketPolicy < ApplicationPolicy
  def index?
    user &&
      user.brand == target_object
  end

  def show?
    user &&
      user.brand == target_object &&
      user.brand == record.brand
  end

  def update?
    user &&
      user.brand == target_object &&
      user.brand == record.brand
  end

  def destroy?
    user &&
      user.brand == target_object &&
      user.brand == record.brand
  end

  def refresh?
    user &&
      user.brand == target_object
  end

  def permalink?
    user &&
      user.brand == target_object
  end
end
