# typed: false
# frozen_string_literal: true

class SessionsController < ApplicationController
  before_action :authenticate!

  def destroy
    sign_out

    redirect_to root_path, flash: { success: 'You have been logged out.' }
  end
end
