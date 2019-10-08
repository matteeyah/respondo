# frozen_string_literal: true

module SignInOutHelpers
  def self.included(base)
    base.class_eval do
      after do
        Account.providers.keys.each do |provider|
          OmniAuth.config.mock_auth.delete(provider.to_sym)
        end
      end
    end
  end

  def sign_in(user)
    account = user.accounts.first
    OmniAuth.config.add_mock(account.provider.to_sym,
                             uid: account.external_uid,
                             info: { name: user.name, email: account.email },
                             credentials: {})
    get "/auth/#{account.provider}?model=user"
    follow_redirect!
    follow_redirect!
  end
end
