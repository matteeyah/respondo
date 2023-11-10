# frozen_string_literal: true

class DashboardController < ApplicationController
  include AuthorizesOrganizationMembership

  def show
    @newest_mentions = newest_mentions
    @new_count = new_mentions.count
    @open_count = current_user.organization.mentions.open.count
    @solved_count = current_user.organization.mentions.solved.count
    @unassigned_count = unassigned_mentions.count
  end

  private

  def new_mentions
    current_user.organization.mentions.open.where(created_at: Time.zone.today)
  end

  def unassigned_mentions
    current_user.organization.mentions.includes(:assignment).where(assignment: { mention_id: nil })
  end

  def newest_mentions
    current_user.organization.mentions.includes(:author, :source).order(created_at: :desc).take(3)
  end
end
