# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def edit?
    user &&
      user == record
  end
end
