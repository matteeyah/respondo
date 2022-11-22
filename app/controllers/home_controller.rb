# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: :login

  def login
    render layout: false
  end

  def index
    redirect_to brand_dashboard_path(current_user.brand) if current_user.brand

    @user = current_user
  end
end
