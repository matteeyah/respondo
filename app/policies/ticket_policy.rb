# frozen_string_literal: true

class TicketPolicy < ApplicationPolicy
  def index?
    user &&
      user.brand == record
  end

  def reply?
    user &&
      user.brand == record.brand
  end

  def internal_note?
    user &&
      user.brand == record.brand
  end

  def invert_status?
    user &&
      user.brand == record.brand
  end

  def refresh?
    user.present?
  end
end
