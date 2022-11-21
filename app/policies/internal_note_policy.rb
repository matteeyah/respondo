# frozen_string_literal: true

class InternalNotePolicy < ApplicationPolicy
  def create?
    user &&
      record == user.brand
  end
end
