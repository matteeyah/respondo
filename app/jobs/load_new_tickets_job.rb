# frozen_string_literal: true

class LoadNewTicketsJob < ApplicationJob
  queue_as :default

  def perform(brand_id)
    Brand.find_by(id: brand_id).try do |brand|
      brand.accounts.each do |account|
        account.new_mentions.each do |mention|
          create_ticket!(account.provider, mention, brand)
        end
      end
    end
  end

  private

  def create_ticket!(provider, mention, brand)
    ticket = case provider
             when 'twitter'
               Ticket.from_tweet!(mention, brand, nil)
             when 'disqus'
               Ticket.from_disqus_post!(mention, brand, nil)
             end

    ticket.parent.open! if ticket.parent&.solved?
  end
end
