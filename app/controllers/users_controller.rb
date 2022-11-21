# frozen_string_literal: true

class UsersController < Users::ApplicationController
  def edit
    authorize(user)
    @user = user
  end
end
