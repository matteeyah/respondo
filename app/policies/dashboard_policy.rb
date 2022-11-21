# frozen_string_literal: true

class DashboardPolicy < ApplicationPolicy
  def index?
    user &&
      user.brand == target_object
  end
end
