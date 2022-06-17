# frozen_string_literal: true

class UsersController < Users::ApplicationController
  include Pundit::Authorization

  def edit
    authorize(user)
    @user = user
  end
end
