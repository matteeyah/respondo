# frozen_string_literal: true

class UsersController < Users::ApplicationController
  include Pundit

  def edit
    authorize(user)
  end
end
