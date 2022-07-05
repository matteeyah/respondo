# frozen_string_literal: true

# This should generally not be included directly. Respective extending modules
# should be included instead (e.g. SignInOutRequestHelpers,
# SignInOutSystemHelpers).
#
# In some cases it's acceptable to include this directly as well.
module OmniauthHelpers
  PROVIDER_OAUTH_FIXTURE = {
    'twitter' => 'twitter_oauth_hash.json',
    'google_oauth2' => 'google_oauth_hash.json',
    'disqus' => 'disqus_oauth_hash.json',
    'activedirectory' => 'activedirectory_oauth_hash.json'
  }.freeze

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

  def self.fixture_for_provider(provider)
    JSON.parse(
      Pathname.new(
        File.join('spec/fixtures/files', PROVIDER_OAUTH_FIXTURE[provider])
      ).read
    )
  end

  def add_oauth_mock(provider, external_uid, info, credentials)
    OmniAuth.config.add_mock(provider,
                             uid: external_uid,
                             info:,
                             credentials:)
  end

  def add_oauth_mock_for_user(user, account = user.accounts.first)
    add_oauth_mock(
      account.provider.to_sym, account.external_uid, { name: user.name, email: account.email },
      token: account.token, secret: account.secret
    )
  end

  def add_oauth_mock_for_brand(brand, account = brand.accounts.first)
    add_oauth_mock(
      account.provider.to_sym, account.external_uid, { nickname: brand.screen_name },
      token: account.token, secret: account.secret
    )
  end
end
