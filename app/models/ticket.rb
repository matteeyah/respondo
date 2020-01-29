# frozen_string_literal: true

class Ticket < ApplicationRecord
  include AASM
  extend RecursiveCte

  validates :external_uid, presence: { allow_blank: false }, uniqueness: { scope: %i[provider brand_id] }
  validates :content, presence: { allow_blank: false }
  validates :provider, presence: true
  validate :parent_in_brand
  serialize :metadata

  enum status: { open: 0, solved: 1 }
  enum provider: { external: 0, twitter: 1, disqus: 2 }

  aasm column: :status, enum: true do
    state :open, initial: true
    state :solved

    event :open do
      before do
        Ticket.where(ancestors_query).update_all(status: 'open') # rubocop:disable Rails/SkipsModelValidations
      end

      transitions from: :solved, to: :open
    end

    event :solve do
      before do
        Ticket.where(descendants_query).update_all(status: 'solved') # rubocop:disable Rails/SkipsModelValidations
      end

      transitions from: :open, to: :solved
    end
  end

  scope :root, -> { where(parent: nil) }

  belongs_to :user, optional: true
  belongs_to :author
  belongs_to :brand

  belongs_to :parent, class_name: 'Ticket', optional: true
  has_many :replies, class_name: 'Ticket', foreign_key: :parent_id, inverse_of: :parent, dependent: :destroy

  has_many :comments, dependent: :restrict_with_error

  class << self
    def search(query)
      authors = Author.arel_table
      where(arel_table[:content].matches("%#{query}%")
        .or(arel_table[:author_id].in(authors.project(authors[:id]).where(authors[:username].matches(query)))))
    end

    def from_tweet!(tweet, brand, user)
      author = Author.from_twitter_user!(tweet.user)
      parent = brand.tickets.twitter.find_by(external_uid: parse_tweet_reply_id(tweet.in_reply_to_tweet_id))
      brand.tickets.twitter.create!(external_uid: tweet.id, author: author, user: user,
                                    parent: parent, content: tweet.attrs[:full_text])
    end

    def from_disqus_post!(post, brand, user)
      author = Author.from_disqus_user!(post[:author])
      parent = brand.tickets.disqus.find_by(external_uid: post[:parent])
      brand.tickets.disqus.create!(external_uid: post[:id], author: author, user: user,
                                   parent: parent, content: post[:raw_message])
    end

    def from_external_ticket!(external_ticket_json, brand, user)
      author = Author.from_external_author!(external_ticket_json[:author])
      parent = brand.tickets.external.find_by(external_uid: external_ticket_json[:parent_uid])
      brand.tickets.external.create!(external_uid: external_ticket_json[:external_uid],
                                     metadata: external_ticket_json[:metadata], content: external_ticket_json[:content],
                                     author: author, user: user, parent: parent)
    end

    def with_descendants_hash(*included_relations)
      ids_query = arel_table[:id].in(self_and_descendants_arel(all.select(:id).arel))
      tickets = Ticket.unscoped.includes(included_relations).where(ids_query)
      convert_ticket_array_to_hash(tickets)
    end

    def self_and_descendants_arel(ticket_ids)
      self_and_recursive_cte_query_arel(:parent_id, :id, ticket_ids)
    end

    def self_and_ancestors_arel(ticket_ids)
      self_and_recursive_cte_query_arel(:id, :parent_id, ticket_ids)
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

    def parse_tweet_reply_id(tweet_id)
      # `Twitter::NullObject#presence` returned another `Twitter::NullObject`
      # https://github.com/sferik/twitter/issues/959
      tweet_id.nil? ? nil : tweet_id
    end
  end

  def provider
    metadata&.dig(:custom_provider) || self[:provider]
  end

  private

  def parent_in_brand
    return unless parent
    return unless parent.brand != brand

    errors.add(:parent, 'must be in same brand as ticket')
  end

  def arel_ids_query_minus_self(query)
    # This removes the calling object's ID from an arel query that queries a list of IDs
    self.class.arel_table[:id].in(query).and(self.class.arel_table[:id].not_eq(id))
  end

  def descendants_query
    arel_ids_query_minus_self(self.class.self_and_descendants_arel(id))
  end

  def ancestors_query
    arel_ids_query_minus_self(self.class.self_and_ancestors_arel(id))
  end
end
