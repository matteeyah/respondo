# frozen_string_literal: true

class InternalNotePolicy < ApplicationPolicy
  def create?
    user &&
      user.brand == target_object.first &&
      target_object.first == target_object.second.brand
  end
end
