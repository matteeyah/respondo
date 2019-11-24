# frozen_string_literal: true

module HasAccounts
  extend ActiveSupport::Concern

  def account_for_provider?(provider)
    accounts.exists?(provider: provider)
  end

  def client_for_provider(provider)
    accounts.find_by(provider: provider)&.client
  end
end
