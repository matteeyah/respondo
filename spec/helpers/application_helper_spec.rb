# frozen_string_literal: true

RSpec.describe ApplicationHelper, type: :helper do
  describe '#auth_provider_link' do
    subject(:auth_provider_link) { helper.auth_provider_link('text', provider, 'model') }

    Account.providers.keys.each do |account_provider|
      context "when provider is #{account_provider}" do
        let(:provider) { account_provider }

        it { is_expected.to match(%r{<a rel="nofollow" data-method="post" href="/auth/.*\?state=model">text</a>}) }
      end
    end
  end
end
