# frozen_string_literal: true

class Ticket < ApplicationRecord
  include AASM

  validates :external_uid, presence: { allow_blank: false }, uniqueness: { scope: %i[ticketable_type brand_id] }
  validates :content, presence: { allow_blank: false }
  validate :parent_in_brand

  enum status: { open: 0, solved: 1 }

  delegated_type :ticketable, types: %w[InternalTicket ExternalTicket]
  delegate :provider, :source, to: :ticketable

  acts_as_taggable_on :tags

  aasm column: :status, enum: true do
    state :open, initial: true
    state :solved
  end

  scope :root, -> { where(parent: nil) }

  belongs_to :creator, optional: true, class_name: 'User'
  belongs_to :author
  belongs_to :brand
  belongs_to :parent, class_name: 'Ticket', optional: true

  has_one :assignment, dependent: :destroy

  has_many :replies, class_name: 'Ticket', foreign_key: :parent_id, inverse_of: :parent, dependent: :destroy
  has_many :internal_notes, dependent: :destroy

  class << self
    def from_tweet!(tweet, source, user)
      Ticket.create!(
        external_uid: tweet.id, content: tweet.attrs[:full_text], created_at: tweet.created_at,
        parent: source.tickets.find_by(external_uid: tweet.in_reply_to_tweet_id.presence), brand: source.brand,
        creator: user, author: Author.from_twitter_user!(tweet.user), ticketable: InternalTicket.new(source:)
      )
    end

    def from_disqus_post!(post, source, user)
      Ticket.create!(
        external_uid: post[:id], content: post[:raw_message], created_at: post[:createdAt],
        parent: source.tickets.find_by(external_uid: post[:parent]), creator: user, brand: source.brand,
        author: Author.from_disqus_user!(post[:author]), ticketable: InternalTicket.new(source:)
      )
    end

    def from_external_ticket!(external_ticket_json, brand, user)
      parent = brand.tickets.find_by(ticketable_type: 'ExternalTicket', external_uid: external_ticket_json[:parent_uid])
      brand.tickets.create!(
        external_uid: external_ticket_json[:external_uid], content: external_ticket_json[:content],
        created_at: external_ticket_json[:created_at], parent:, creator: user,
        author: Author.from_external_author!(external_ticket_json[:author]),
        ticketable: ExternalTicket.new(response_url: external_ticket_json[:response_url],
                                       custom_provider: external_ticket_json[:custom_provider])
      )
    end

    def with_descendants_hash(*included_relations)
      tickets = all.with_descendants.includes(included_relations)
      convert_ticket_array_to_hash(tickets)
    end

    def with_descendants
      RecursiveCteQuery.new(all, model_column: :parent_id, recursive_cte_column: :id).call
    end

    private

    def convert_ticket_array_to_hash(tickets)
      {}.extend(Hashie::Extensions::DeepFind).tap do |hash|
        tickets.each do |ticket|
          # This is used instead of ticket.parent to prevent an additional DB query
          parent = tickets.find { |parent_ticket| parent_ticket.id == ticket.parent_id }
          # Either add to the ticket hash key or create a root key for the ticket
          (hash.deep_find(parent) || hash).merge!(ticket => {})
        end
      end
    end
  end

  private

  def parent_in_brand
    return unless parent
    return unless parent.brand != brand

    errors.add(:parent, 'must be in same brand as ticket')
  end
end
