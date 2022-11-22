# frozen_string_literal: true

class OmniauthCallbacksController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  def create # rubocop:disable Metrics/AbcSize
    return redirect_to login_path if current_user.nil? && request.env['omniauth.params']['state'] == 'brand'

    omniauth_hash = request.env['omniauth.auth']
    redirect_uri = request.env['omniauth.origin'] || root_path

    case request.env['omniauth.params']['state']
    when 'user'
      authenticate_user(omniauth_hash)
    when 'brand'
      authenticate_brand(omniauth_hash)
    end

    redirect_to redirect_uri
  end

  private

  def authenticate_user(auth_hash)
    account = UserAccount.from_omniauth(auth_hash, current_user)

    sign_in(account.user) if account.persisted? && current_user.nil?
  end

  def authenticate_brand(auth_hash)
    return if current_user.nil?

    account = BrandAccount.from_omniauth(auth_hash, current_user.brand)

    # This checks if the account was just created.
    LoadNewTicketsJob.perform_later(account.brand) if account.id_previously_changed?
    current_user.update(brand: account.brand) if account.persisted?
  end
end
