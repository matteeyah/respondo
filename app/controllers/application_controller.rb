# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  protected

  def authenticate!
    return if user_signed_in?

    redirect_back fallback_location: root_path, flash: { warning: 'You are not signed in.' }
  end

  def sign_in(user)
    session[:user_id] = user.id
  end

  def sign_out
    session[:user_id] = nil
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

  def current_brand
    @current_brand ||= current_user&.brand
  end
  helper_method :current_brand

  def user_signed_in?
    !current_user.nil?
  end
  helper_method :user_signed_in?
end
