# frozen_string_literal: true

class LoadNewTicketsJob < ApplicationJob
  queue_as :default

  def perform(organization)
    organization.accounts.each do |account|
      account.new_mentions.each do |mention|
        Ticket.from_client_response!(account.provider, mention, account, nil)
      end
    end
  end
end
