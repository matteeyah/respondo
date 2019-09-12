# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user, :current_brand, :user_signed_in?, :brand_signed_in?

  protected

  def authenticate!
    return unless user_signed_in?

    redirect_back fallback_location: root_path, alert: 'You are not allowed'
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def current_brand
    @current_brand ||= current_user&.brand
  end

  def user_signed_in?
    # converts current_user to a boolean by negating the negation
    !current_user.nil?
  end

  def brand_signed_in?
    !current_brand.nil?
  end
end
