# frozen_string_literal: true

class ReplyPolicy < ApplicationPolicy
  def create?
    user &&
      user.brand == record
  end
end
