# frozen_string_literal: true

class Ticket < ApplicationRecord
  belongs_to :author
  belongs_to :brand

  belongs_to :parent, class_name: 'Ticket', optional: true
  has_many :replies, class_name: 'Ticket', foreign_key: :parent_id

  scope :root, ->() { where(parent: nil) }

  class << self
    def from_tweet(tweet, brand)
      # Setting the parent inside #first_or_create results in weirdness.
      # Most likely due to the scope being manipulated by `#unscoped`.
      twitter_ticket = find_or_create_by(external_uid: tweet.id) do |ticket|
        ticket.content = tweet.text
        ticket.brand = brand
        ticket.author = Author.from_twitter_user(tweet.user)
      end

      twitter_ticket.tap { |ticket| ticket.parent = find_by(external_uid: parse_tweet_reply_id(tweet.in_reply_to_tweet_id)) }
    end

    private

    def parse_tweet_reply_id(tweet_id)
      # `Twitter::NullObject#presence` returned another `Twitter::NullObject`
      # https://github.com/sferik/twitter/issues/959
      tweet_id.nil? ? nil : tweet_id
    end
  end
end
