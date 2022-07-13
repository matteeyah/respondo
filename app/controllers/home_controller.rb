# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :authenticate!, only: :index

  def login
    render layout: false
  end

  def index
    @brand = current_brand
    @user = current_user
    @newest = newest_tickets.take(3)
    @open_count = current_brand.tickets.open.count
    @solved_count = current_brand.tickets.solved.count
    @new_count = new_tickets.count
  end

  private

  def authenticate!
    return unless current_user.nil?

    redirect_back fallback_location: login_path, flash: { warning: 'You are not signed in.' }
  end

  def new_tickets
    current_brand.tickets.open.where(created_at: Time.zone.today)
  end

  def newest_tickets
    current_brand.tickets.order(created_at: :desc)
  end
end
