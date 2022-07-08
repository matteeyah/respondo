# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :authenticate!, only: :index

  def login
    render layout: false
  end

  def index
    @brand = current_brand
    @user = current_user
    @newest = current_brand&.tickets&.order(created_at: :desc)&.first(3)
    @total_open = current_brand&.tickets&.select { |e| e.status == 'open' }.count
    @total_resolved = current_brand&.tickets&.select { |e| e.status == 'solved' }.count
    @total_new = current_brand&.tickets&.select do |e|
      e.created_at.strftime('%d %b %y') == Time.zone.now.strftime('%d %b %y') && e.status == 'open'
    end.count
  end

  private

  def authenticate!
    return unless current_user.nil?

    redirect_back fallback_location: login_path, flash: { warning: 'You are not signed in.' }
  end
end
