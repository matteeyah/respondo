# frozen_string_literal: true

class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new ]

  def new
    render layout: false
  end

  def destroy
    terminate_session

    redirect_to login_path
  end
end
