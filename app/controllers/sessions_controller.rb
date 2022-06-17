# frozen_string_literal: true

class SessionsController < ApplicationController
  before_action :authenticate!

  def destroy
    sign_out

    redirect_to login_path
  end

  private

  def authenticate!
    return unless current_user.nil?

    redirect_back fallback_location: login_path, flash: { warning: 'You are not signed in.' }
  end
end
