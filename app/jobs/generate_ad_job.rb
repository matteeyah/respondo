# frozen_string_literal: true

class GenerateAdJob < ApplicationJob
  before_perform do |job|
    @description = job.arguments.second
    @authors = job.arguments[2..]
  end

  def perform(guid, _description, *_authors)
    response = OpenAI::Client.new.chat(
      parameters: { model: "gpt-4", messages: ai_messages, temperature: 0.7 }
    ).dig("choices", 0, "message", "content").chomp.strip

    Turbo::StreamsChannel.broadcast_replace_to(
      guid, :ad, target: "ad-output", partial: "ads/ad", locals: { content: response }
    )
  end

  private

  def posts
    @authors.map { |author| author.posts.pluck("text") }.flatten
  end

  def ai_messages # rubocop:disable Metrics/MethodLength
    [
      {
        role: "system",
        content: <<~AI_POSITION
          You are a marketing specialist at a startup.
          You are given a description of a product and a list of social media posts from the user.
          Messages from the user are social media posts for potential buyers of the product. They are from various authors.
          You respond with an ad optimized for selling to the authors of those social media posts.
        AI_POSITION
      },
      {
        role: "user",
        content: "Product description: #{@description}"
      }
    ] + posts.map { |post| { role: "user", content: post } }
  end
end
