# frozen_string_literal: true

class GenerateAdJob < ApplicationJob
  def perform(guid, description, *authors)
    merged_posts = {}
    authors.each do |author|
      merged_posts[author.username] = author.author_posts
    end

    Turbo::StreamsChannel.broadcast_replace_to(
      guid, :ad,
      target: 'ad-output', partial: 'ads/ad',
      locals: { content: "#{description} by #{authors.map(&:username).join(', ')}", posts: merged_posts.values.flatten }
    )
  end
end
