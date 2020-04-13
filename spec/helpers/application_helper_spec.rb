# frozen_string_literal: true

RSpec.describe ApplicationHelper, type: :helper do
  describe '#auth_provider_link' do
    subject(:auth_provider_link) { helper.auth_provider_link('text', provider, 'model') }

    (UserAccount.providers.keys + BrandAccount.providers.keys).each do |account_provider|
      context "when provider is #{account_provider}" do
        let(:provider) { account_provider }

        it { is_expected.to match(%r{<a rel="nofollow" data-method="post" href="/auth/.*\?state=model">text</a>}) }
      end
    end
  end

  describe '#provider_human_name' do
    subject(:provider_human_name) { helper.provider_human_name(provider) }

    (UserAccount.providers.keys + BrandAccount.providers.keys).each do |account_provider|
      context "when provider is #{account_provider}" do
        let(:provider) { account_provider }

        it 'returns human mame' do
          expect(provider_human_name).to be_an_instance_of(String)
        end
      end
    end
  end

  describe '#safe_blank_link_to' do
    subject(:safe_blank_link_to) { helper.safe_blank_link_to('Link Text', 'https://example.com') }

    it { is_expected.to eq('<a target="_blank" rel="noopener noreferrer" href="https://example.com">Link Text</a>') }
  end

  describe '#fa_icon' do
    subject(:fa_icon) { helper.fa_icon('test') }

    it { is_expected.to eq('<i class="fas fa-test"></i>') }
  end
end
