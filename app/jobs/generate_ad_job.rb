# frozen_string_literal: true

class GenerateAdJob < ApplicationJob
  def perform(guid, description, author)
    posts = author.author_posts

    Turbo::StreamsChannel.broadcast_replace_to(
      guid, :ad,
      target: 'ad-output', partial: 'ads/ad',
      locals: { content: "#{description} by #{author[:username]}", posts: }
    )
  end
end
