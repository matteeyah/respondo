# frozen_string_literal: true

# Only system type specs should need to include this module directly.
# Request type specs should include SignInOutHelpers.
module OmniauthHelpers
  # Clear OmniAuth mocks in all specs that include this module.
  def self.included(base)
    base.class_eval do
      after do
        OmniAuth.config.mock_auth.slice!(:default)
      end
    end
  end

  # Clear OmniAuth mocks in all specs that include modules that extend this
  # module - e.g. SignInOutHelpers
  def self.extended(base)
    base.class_eval do
      define_singleton_method(:included) do |included_base|
        included_base.class_eval do
          after do
            OmniAuth.config.mock_auth.slice!(:default)
          end
        end
      end
    end
  end

  def add_oauth_mock(provider, external_uid, info, credentials)
    OmniAuth.config.add_mock(provider,
                             uid: external_uid,
                             info: info,
                             credentials: credentials)
  end

  def add_oauth_mock_for_user(user, account = user.accounts.first)
    add_oauth_mock(account.provider.to_sym, account.external_uid, { name: user.name, email: account.email }, {})
  end

  def add_oauth_mock_for_brand(brand)
    add_oauth_mock(:twitter, brand.external_uid, { nickname: brand.screen_name }, {})
  end
end
