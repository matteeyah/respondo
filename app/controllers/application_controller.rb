# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  etag { Rails.application.importmap.digest(resolver: helpers) if request.format&.html? }

  protect_from_forgery with: :exception

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def user_not_authorized(_exception)
    redirect_back fallback_location: root_path
  end

  def sign_in(user)
    session[:user_id] = user.id
  end

  def sign_out
    session[:user_id] = nil
  end

  def current_user
    return unless session[:user_id]

    @current_user ||= begin
      User.find_by(id: session[:user_id])
    end.tap do |user|
      session[:user_id] = nil unless user
    end
  end
  helper_method :current_user

  def current_brand
    @current_brand ||= current_user&.brand
  end
  helper_method :current_brand

  def pundit_user
    [current_user, current_brand]
  end
end
