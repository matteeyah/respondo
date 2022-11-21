# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :authenticate!, only: :index

  def login
    render layout: false
  end

  def index
    redirect_to brand_dashboard_path(current_user.brand) if current_user.brand

    @user = current_user
  end

  private

  def authenticate!
    return unless current_user.nil?

    redirect_back fallback_location: login_path
  end
end
