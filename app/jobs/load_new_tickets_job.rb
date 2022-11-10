# frozen_string_literal: true

class LoadNewTicketsJob < ApplicationJob
  queue_as :default

  def perform(brand_id)
    Brand.find_by(id: brand_id).try do |brand|
      brand.accounts.each do |account|
        account.new_mentions.each do |mention|
          Ticket.from_client_response!(account.provider, mention, account, nil)
        end
      end
    end
  end
end
