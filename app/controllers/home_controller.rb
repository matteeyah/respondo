# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: :login

  def login
    render layout: false
  end

  def index
    redirect_to dashboard_path if current_user.organization

    @user = current_user
  end
end
