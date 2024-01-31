# frozen_string_literal: true

class UserAccount < ApplicationRecord
  validates :external_uid, presence: { allow_blank: false }
  validates :provider, presence: true, uniqueness: { scope: :user_id }
  validates :email, presence: { allow_blank: false, allow_nil: true }

  enum provider: { google_oauth2: 0, azure_activedirectory_v2: 1 }

  belongs_to :user

  before_destroy :validate_not_last_account

  class << self
    def from_omniauth(auth, current_user) # rubocop:disable Metrics/AbcSize
      find_or_initialize_by(external_uid: auth.uid, provider: auth.provider).tap do |account|
        account.email = auth.info.email

        account.user = current_user || account.user || User.new(name: auth.info.name)
        account.user.organization ||= find_organization(account.email)

        account.user.save
        account.save
      end
    end

    private

    def find_organization(user_email)
      return unless user_email

      user_domain = user_email.split("@").last
      Organization.find_by(domain: user_domain)
    end
  end

  def screen_name
    email
  end

  private

  def validate_not_last_account
    return if user.accounts.count > 1

    errors.add(:base, "You can not delete the last user account.")
    throw(:abort)
  end
end
