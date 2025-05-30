# frozen_string_literal: true

class DashboardController < ApplicationController
  def show
    return redirect_to new_onboarding_path unless Current.user.organization

    @newest_mentions = newest_mentions
    @new_count = new_mentions.count
    @open_count = Current.user.organization.mentions.open.count
    @solved_count = Current.user.organization.mentions.solved.count
    @unassigned_count = unassigned_mentions.count
  end

  private

  def new_mentions
    Current.user.organization.mentions.open.where(created_at: Time.zone.today)
  end

  def unassigned_mentions
    Current.user.organization.mentions.includes(:assignment).where(assignment: { mention_id: nil })
  end

  def newest_mentions
    Current.user.organization.mentions.includes(:author, :source).order(created_at: :desc).take(3)
  end
end
