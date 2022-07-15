# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :authenticate!, only: :index

  def login
    render layout: false
  end

  def index
    @brand = current_brand
    @user = current_user
  end

  private

  def authenticate!
    return unless current_user.nil?

    redirect_back fallback_location: login_path
  end
end
