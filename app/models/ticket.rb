# frozen_string_literal: true

class Ticket < ApplicationRecord
  validates :external_uid, presence: true, allow_blank: false, uniqueness: { scope: %i[provider brand_id] }
  validates :content, presence: true, allow_blank: false
  validates :provider, presence: true

  before_save :cascade_status

  belongs_to :author
  belongs_to :brand

  belongs_to :parent, class_name: 'Ticket', optional: true
  has_many :replies, class_name: 'Ticket', foreign_key: :parent_id, inverse_of: :parent, dependent: :destroy

  scope :root, -> { where(parent: nil) }

  enum status: { open: 0, solved: 1 }
  enum provider: { twitter: 0, google_oauth2: 1 }

  class << self
    def from_tweet(tweet, brand)
      twitter_ticket = brand.tickets.find_or_create_by(external_uid: tweet.id, provider: 'twitter') do |ticket|
        ticket.content = tweet.text
        ticket.author = Author.from_twitter_user(tweet.user)
      end

      # Setting the parent inside #find_or_create_by results in weirdness.
      # Most likely due to inheriting scope when attempting to find_by.
      twitter_ticket.tap do |ticket|
        ticket.update(parent: find_by(external_uid: parse_tweet_reply_id(tweet.in_reply_to_tweet_id)))
      end
    end

    private

    def parse_tweet_reply_id(tweet_id)
      # `Twitter::NullObject#presence` returned another `Twitter::NullObject`
      # https://github.com/sferik/twitter/issues/959
      tweet_id.nil? ? nil : tweet_id
    end
  end

  private

  def cascade_status
    return unless status_changed?

    replies.update(status: status)
  end
end
