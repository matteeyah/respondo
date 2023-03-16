# frozen_string_literal: true

# This should generally not be included directly. Respective extending modules
# should be included instead (e.g. SignInOutRequestHelpers,
# AuthenticationHelper).
#
# In some cases it's acceptable to include this directly as well.
module OmniauthHelper
  # Clear OmniAuth mocks in all specs that include this module.
  def self.included(base)
    base.class_eval do
      teardown do
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
          teardown do
            OmniAuth.config.mock_auth.slice!(:default)
          end
        end
      end
    end
  end

  def add_oauth_mock(provider, external_uid, info, credentials)
    OmniAuth.config.add_mock(provider,
                             uid: external_uid,
                             info:,
                             credentials:)
  end

  def add_oauth_mock_for_user(user, account)
    add_oauth_mock(
      account.provider.to_sym, account.external_uid, { name: user.name, email: account.email }, nil
    )
  end

  def add_oauth_mock_for_organization(organization, account)
    add_oauth_mock(
      account.provider.to_sym, account.external_uid, { nickname: organization.screen_name },
      token: account.token, secret: account.secret
    )
  end
end
