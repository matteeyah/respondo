# frozen_string_literal: true

RSpec.describe ApplicationHelper, type: :helper do
  describe '#auth_twitter_link' do
    subject(:auth_twitter_link) { helper.auth_twitter_link('text', 'model') }

    it { is_expected.to include('/auth/twitter?model=model') }
    it { is_expected.to include('data-method="post"') }
    it { is_expected.to include('text') }
  end

  describe '#auth_google_link' do
    subject(:auth_google_link) { helper.auth_google_link('text', 'model') }

    it { is_expected.to include('/auth/google_oauth2?model=model') }
    it { is_expected.to include('data-method="post"') }
    it { is_expected.to include('text') }
  end
end
