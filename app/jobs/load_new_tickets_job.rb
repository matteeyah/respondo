# frozen_string_literal: true

class LoadNewTicketsJob < ApplicationJob
  queue_as :default

  def perform(organization)
    organization.accounts.each do |account|
      account.new_mentions.each do |mention|
        parent = account.tickets.find_by(ticketable_type: 'InternalTicket', external_uid: mention[:parent_uid])
        author = Author.from_client!(mention[:author], account.provider)

        organization.tickets.create!(
          **mention.except(:parent_uid, :author), ticketable_type: 'InternalTicket',
          author:, parent:, creator: nil, ticketable_attributes: { source: account }
        )
      end
    end
  end
end
