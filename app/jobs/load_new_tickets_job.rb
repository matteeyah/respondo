# frozen_string_literal: true

class LoadNewTicketsJob < ApplicationJob
  queue_as :default

  def perform(organization)
    organization.accounts.each do |account|
      account.new_mentions.each do |mention|
        organization.tickets.create!(
          **mention.except(:parent_uid, :author),
          ticketable_type: 'InternalTicket', ticketable_attributes: { source: account },
          author: Author.from_client!(mention[:author], account.provider),
          parent: account.tickets.find_by(ticketable_type: 'InternalTicket', external_uid: mention[:parent_uid])
        )
      end
    end
  end
end
