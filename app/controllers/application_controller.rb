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
    return unless session[:user_id]

    user = User.find_by(id: session[:user_id])
    session[:user_id] = nil unless user

    @current_user ||= user
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
