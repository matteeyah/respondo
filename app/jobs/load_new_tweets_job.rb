# frozen_string_literal: true

class LoadNewTweetsJob < ApplicationJob
  queue_as :default

  def perform(brand_id)
    Brand.find_by(id: brand_id).try do |brand|
      brand.new_mentions.reverse_each do |tweet|
        ticket = Ticket.from_tweet!(tweet, brand, nil)
        ticket.parent.open! if ticket.parent&.solved?
      end
    end
  end
end
