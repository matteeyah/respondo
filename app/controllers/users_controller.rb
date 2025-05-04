# frozen_string_literal: true

class UsersController < ApplicationController
  def edit
    @user = Current.user
  end
end
