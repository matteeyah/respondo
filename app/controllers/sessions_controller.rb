# frozen_string_literal: true

class SessionsController < ApplicationController
  def destroy
    sign_out

    redirect_to login_path
  end
end
