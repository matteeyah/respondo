# frozen_string_literal: true

class OmniauthCallbacksController < ApplicationController
  skip_before_action :verify_authenticity_token

  allow_unauthenticated_access only: %i[ user ]
  rate_limit to: 10, within: 3.minutes, only: [ :user, :organization ], with: -> { redirect_to login_url, alert: "Try again later." }

  def user
    account = UserAccount.from_omniauth(auth_hash, Current.user)

    start_new_session_for(account.user) if account.persisted? && Current.user.nil?

    redirect_to (auth_origin || after_authentication_url)
  end

  def organization
    account = OrganizationAccount.from_omniauth(auth_hash, Current.user.organization)

    # This checks if the account was just created.
    LoadNewMentionsJob.perform_later(account.organization) if account.id_previously_changed?
    Current.user.update!(organization: account.organization) if account.persisted?

    redirect_to (auth_origin || after_authentication_url)
  end

  private

  def auth_hash
    request.env["omniauth.auth"]
  end

  def auth_origin
    request.env["omniauth.origin"]
  end
end
