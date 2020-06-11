# frozen_string_literal: true

class TicketPolicy < ApplicationPolicy
  def reply?
    raise Pundit::NotAuthorizedError, query: :authenticate? unless user

    user.brand == record.brand ||
      user.client_for_provider(record.provider)
  end

  def internal_note?
    raise Pundit::NotAuthorizedError, query: :authenticate? unless user

    user.brand == record.brand
  end

  def invert_status?
    raise Pundit::NotAuthorizedError, query: :authenticate? unless user

    user.brand == record.brand
  end

  def refresh?
    raise Pundit::NotAuthorizedError, query: :authenticate? unless user

    true
  end
end
