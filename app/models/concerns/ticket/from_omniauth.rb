# frozen_string_literal: true

class Ticket
  module FromOmniauth
    extend ActiveSupport::Concern

    class_methods do # rubocop:disable Metrics/BlockLength
      def from_client_response!(provider, body, source, user)
        case provider
        when 'twitter'
          Ticket.from_tweet!(body, source, user)
        when 'disqus'
          Ticket.from_disqus_post!(body, source, user)
        when 'external'
          Ticket.from_external_ticket!(body, source, user)
        end
      end

      def from_tweet!(tweet, source, user)
        Ticket.create!(
          external_uid: tweet.id, content: tweet.attrs[:full_text], created_at: tweet.created_at,
          parent: source.tickets.find_by(external_uid: tweet.in_reply_to_tweet_id.presence),
          organization: source.organization, creator: user, author: Author.from_twitter_user!(tweet.user),
          ticketable: InternalTicket.new(source:)
        )
      end

      def from_disqus_post!(post, source, user)
        Ticket.create!(
          external_uid: post[:id], content: post[:raw_message], created_at: post[:createdAt],
          parent: source.tickets.find_by(external_uid: post[:parent]), creator: user, organization: source.organization,
          author: Author.from_disqus_user!(post[:author]), ticketable: InternalTicket.new(source:)
        )
      end

      def from_external_ticket!(external_ticket_json, organization, user)
        parent = organization.tickets.find_by(ticketable_type: 'ExternalTicket',
                                              external_uid: external_ticket_json[:parent_uid])
        organization.tickets.create!(
          external_uid: external_ticket_json[:external_uid], content: external_ticket_json[:content],
          created_at: external_ticket_json[:created_at], parent:, creator: user,
          author: Author.from_external_author!(external_ticket_json[:author]),
          ticketable: ExternalTicket.new(response_url: external_ticket_json[:response_url],
                                         custom_provider: external_ticket_json[:custom_provider])
        )
      end
    end
  end
end
