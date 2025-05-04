# frozen_string_literal: true

class OnboardingsController < ApplicationController
  def new
    @user = Current.user
  end
end
