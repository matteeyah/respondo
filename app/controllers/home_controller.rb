# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    redirect_to dashboard_path if current_user.organization

    @user = current_user
  end
end
