# frozen_string_literal: true

class TicketPolicy < ApplicationPolicy
  def reply?
    user &&
      (user.brand == record.brand ||
      user.client_for_provider(record.provider))
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
