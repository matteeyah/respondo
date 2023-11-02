# frozen_string_literal: true

class LoadNewTicketsJob < ApplicationJob
  queue_as :default

  def perform(organization) # rubocop:disable Metrics/MethodLength
    organization.accounts.each do |account|
      account.new_mentions.each do |mention|
        organization.tickets.create!(
          **mention.except(:parent_uid, :author),
          ticketable_type: 'InternalTicket', ticketable_attributes: { source: account },
          author: Author.from_client!(mention[:author], account.provider),
          parent: account.tickets.find_by(ticketable_type: 'InternalTicket', external_uid: mention[:parent_uid]),
          created_at: mention[:created_at], external_link: mention[:external_link]
        )
      end
    end
  end
end
