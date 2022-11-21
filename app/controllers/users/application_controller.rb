# frozen_string_literal: true

module Users
  class ApplicationController < ::ApplicationController
    private

    def user
      @user ||= User.find(params[:user_id] || params[:id])
    end

    def pundit_user
      [current_user, user]
    end
  end
end
