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
    def create_from_tweet(tweet, brand)
      author = Author.from_twitter_user(tweet.user)
      parent = find_by(external_uid: parse_tweet_reply_id(tweet.in_reply_to_tweet_id))
      brand.tickets.create(external_uid: tweet.id, provider: 'twitter', content: tweet.text, author: author, parent: parent)
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
