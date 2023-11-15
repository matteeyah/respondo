# frozen_string_literal: true

class GenerateAdJob < ApplicationJob
  def perform(guid, description, *authors)
    sleep 3

    Turbo::StreamsChannel.broadcast_replace_to(
      guid, :ad,
      target: 'ad-output', partial: 'ads/ad',
      locals: { content: "#{description} by #{authors.map(&:username).join(', ')}" }
    )
  end
end
