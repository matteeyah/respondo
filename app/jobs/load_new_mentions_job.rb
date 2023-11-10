# frozen_string_literal: true

class LoadNewMentionsJob < ApplicationJob
  queue_as :default

  def perform(organization)
    organization.accounts.each do |account|
      account.new_mentions.each do |mention|
        organization.mentions.create!(
          **mention.except(:parent_uid, :author),
          source: account, author: Author.from_client!(mention[:author], account.provider),
          parent: account.mentions.find_by(external_uid: mention[:parent_uid]),
          created_at: mention[:created_at], external_link: mention[:external_link]
        )
      end
    end
  end
end
