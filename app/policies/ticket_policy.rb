# frozen_string_literal: true

class TicketPolicy < ApplicationPolicy
  def index?
    user &&
      user.brand == record
  end

  def show?
    user &&
      user.brand == record.brand
  end

  def update?
    user &&
      user.brand == record.brand
  end

  def destroy?
    user &&
      user.brand == record.brand
  end

  def reply?
    user &&
      user.brand == record.brand
  end

  def internal_note?
    user &&
      user.brand == record.brand
  end

  def refresh?
    # There's a subsequent check if the user is in the brand.
    user.present?
  end

  def permalink?
    user &&
      user.brand == record.brand
  end
end
