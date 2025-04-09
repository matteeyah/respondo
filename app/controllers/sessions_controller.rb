# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: :new

  def new
    render layout: false
  end

  def destroy
    reset_session

    redirect_to login_path
  end
end
