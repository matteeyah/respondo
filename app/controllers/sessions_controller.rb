# frozen_string_literal: true

class SessionsController < ApplicationController
  before_action :authenticate!, only: [:destroy]

  def destroy
    sign_out

    redirect_to root_path
  end
end
