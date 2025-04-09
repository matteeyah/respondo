# frozen_string_literal: true

class OnboardingsController < ApplicationController
  def new
    @user = current_user
  end
end
