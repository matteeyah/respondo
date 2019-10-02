# frozen_string_literal: true

module Users
  class ApplicationController < ::ApplicationController
    private

    def user
      @user ||= User.find(params[:user_id] || params[:id])
    end
    helper_method :user

    def authorize!
      return if user == current_user

      redirect_back fallback_location: root_path, alert: 'You are not allowed to edit the user.'
    end
  end
end
