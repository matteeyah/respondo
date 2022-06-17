# frozen_string_literal: true

class HomeController < ApplicationController
  def login
    render layout: false
  end

  def index
    @brand = current_brand
    @user = current_user
  end
end
