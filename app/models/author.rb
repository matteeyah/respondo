# frozen_string_literal: true

class Author < ApplicationRecord
  validates :external_uid, presence: { allow_blank: false }, uniqueness: { scope: :provider }
  validates :username, presence: { allow_blank: false }
  validates :external_link, presence: { allow_blank: false }, url: true
  validates :provider, presence: true

  enum provider: { external: 0, twitter: 1, linkedin: 2, email: 3 }

  belongs_to :organization

  has_many :mentions, dependent: :restrict_with_error

  def self.from_client!(author_hash, provider, organization)
    find_or_initialize_by(external_uid: author_hash[:external_uid], provider:).tap do |author|
      author.username = author_hash[:username]
      author.external_link = author_hash[:external_link]
      author.organization = organization
      author.save!
    end
  end

  def posts
    organization.accounts.find_by!(provider:).client.posts(external_uid)
  end
end
