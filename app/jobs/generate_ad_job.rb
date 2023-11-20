# frozen_string_literal: true

class GenerateAdJob < ApplicationJob
  def perform(guid, description, *authors)
    merged_posts = authors.map(&:posts).flatten

    Turbo::StreamsChannel.broadcast_replace_to(
      guid, :ad,
      target: 'ad-output', partial: 'ads/ad',
      locals: { content: "#{description} by #{authors.map(&:username).join(', ')}", posts: merged_posts }
    )
  end
end
