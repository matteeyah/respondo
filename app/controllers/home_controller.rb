# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :authenticate!, only: :index
  before_action :newest, only: :index
  before_action :newest_count, only: :index
  before_action :tickets_overview_open, only: :index
  before_action :tickets_overview_resolved, only: :index

  def login
    render layout: false
  end

  def index
    @brand = current_brand
    @user = current_user
  end

  private

  def newest
    @newest = current_brand&.tickets&.order(created_at: :desc)&.first(3)
  end

  def tickets_overview_open
    @total_open = current_brand&.tickets&.select { |e| e.status == 'open' }&.count
  end

  def tickets_overview_resolved
    @total_resolved = current_brand&.tickets&.select { |e| e.status == 'solved' }&.count
  end

  def newest_count
    @total_new = current_brand&.tickets&.select do |e|
      e.created_at.strftime('%d %b %y') == Time.zone.now.strftime('%d %b %y') && e.status == 'open'
    end&.count
  end

  def authenticate!
    return unless current_user.nil?

    redirect_back fallback_location: login_path, flash: { warning: 'You are not signed in.' }
  end
end
