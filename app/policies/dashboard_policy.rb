# frozen_string_literal: true

class DashboardPolicy < ApplicationPolicy
  def index?
    user &&
      record == user.brand
  end
end
