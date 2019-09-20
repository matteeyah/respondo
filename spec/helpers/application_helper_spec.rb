# frozen_string_literal: true

RSpec.describe ApplicationHelper, type: :helper do
  describe '#auth_twitter_path' do
    subject(:auth_twitter_path) { helper.auth_twitter_path({}) }

    it { is_expected.to start_with('/auth/twitter?') }
  end

  describe '#auth_google_oauth2_path' do
    subject(:auth_google_oauth2_path) { helper.auth_google_oauth2_path({}) }

    it { is_expected.to start_with('/auth/google_oauth2?') }
  end
end
