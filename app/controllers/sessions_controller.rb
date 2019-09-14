# frozen_string_literal: true

class SessionsController < ApplicationController
  def destroy
    sign_out

    redirect_to root_path
  end
end
