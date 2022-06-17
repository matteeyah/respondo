# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @brand = current_brand
    @user = current_user
  end
end
