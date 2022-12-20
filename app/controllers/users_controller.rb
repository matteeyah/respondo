# frozen_string_literal: true

class UsersController < ApplicationController
  def edit
    @user = current_user
  end
end
