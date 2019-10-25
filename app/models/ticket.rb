# frozen_string_literal: true

class Ticket < ApplicationRecord
  validates :external_uid, presence: true, allow_blank: false, uniqueness: { scope: %i[provider brand_id] }
  validates :content, presence: true, allow_blank: false
  validates :provider, presence: true

  before_save :cascade_status

  enum status: { open: 0, solved: 1 }
  enum provider: { twitter: 0 }

  scope :root, -> { where(parent: nil) }

  belongs_to :author
  belongs_to :brand

  belongs_to :parent, class_name: 'Ticket', optional: true
  has_many :replies, class_name: 'Ticket', foreign_key: :parent_id, inverse_of: :parent, dependent: :destroy

  class << self
    def from_tweet(tweet, brand)
      author = Author.from_twitter_user(tweet.user)
      parent = find_by(external_uid: parse_tweet_reply_id(tweet.in_reply_to_tweet_id))
      brand.tickets.create(
        external_uid: tweet.id, author: author, parent: parent,
        provider: 'twitter', content: tweet.attrs[:full_text]
      )
    end

    def with_descendants_hash(included_relations = nil)
      ids_query = arel_table[:id].in(self_and_descendants_arel(all.select(:id).arel))
      tickets = Ticket.unscoped.includes(included_relations).where(ids_query)
      convert_ticket_array_to_hash(tickets)
    end

    def self_and_descendants_arel(ticket_ids) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      # WITH RECURSIVE "ticket_tree" AS (
      #   SELECT "tickets".* FROM "tickets" WHERE "tickets"."id" IN (TICKET_IDS)
      #   UNION ALL
      #   SELECT "tickets".* FROM "tickets" INNER JOIN "ticket_tree" ON "tickets"."parent_id" = "ticket_tree"."id"
      # ) SELECT "ticket_tree"."id" FROM "ticket_tree"
      # This recursive SQL allows us to get all descendant tickets given a ticket
      # id. The method itself represents this recursive CTE SQL query in arel.
      ticket_tree = Arel::Table.new(:ticket_tree)
      select_manager = Arel::SelectManager.new(ActiveRecord::Base).freeze

      non_recursive_term = select_manager.dup.tap do |m|
        m.from(arel_table)
        m.project(arel_table[Arel.star])
        m.where(arel_table[:id].in(ticket_ids))
      end

      recursive_term = select_manager.dup.tap do |m|
        m.from(arel_table)
        m.join(ticket_tree)
        m.on(arel_table[:parent_id].eq(ticket_tree[:id]))
        m.project(arel_table[Arel.star])
      end

      union = non_recursive_term.union(:all, recursive_term)
      as_statement = Arel::Nodes::As.new(ticket_tree, union)

      select_manager.dup.tap do |m|
        m.from(ticket_tree)
        m.with(:recursive, as_statement)
        m.project(ticket_tree[:id])
      end
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

  private

  def descendants_query
    self.class.arel_table[:id].in(self.class.self_and_descendants_arel(id))
      .and(self.class.arel_table[:id].not_eq(id))
  end

  def cascade_status
    return unless status_changed?

    Ticket.where(descendants_query).update_all(status: status) # rubocop:disable Rails/SkipsModelValidations
  end
end
