# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  etag { Rails.application.importmap.digest(resolver: helpers) if request.format&.html? }

  protect_from_forgery with: :exception

  protected

  def sign_in(user)
    session[:user_id] = user.id
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

  def authenticate_user!
    return unless current_user.nil?

    redirect_to login_path
  end
end
