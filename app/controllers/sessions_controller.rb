# frozen_string_literal: true

class SessionsController < ApplicationController
  before_action :authenticate!

  def destroy
    sign_out

    redirect_to root_path, flash: { success: 'You have been signed out.' }
  end

  private

  def authenticate!
    return unless current_user.nil?

    redirect_back fallback_location: root_path, flash: { warning: 'You are not signed in.' }
  end
end
