# frozen_string_literal: true

class LoadTicketsJob < ApplicationJob
  queue_as :default

  def perform(brand_id)
    Brand.find_by(id: brand_id).try do |brand|
      brand.new_mentions.each do |tweet|
        Ticket.from_tweet(tweet, brand)
      end
    end
  end
end
