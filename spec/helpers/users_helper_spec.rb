# frozen_string_literal: true

RSpec.describe UsersHelper, type: :helper do
  describe '#provider_human_name' do
    subject(:provider_human_name) { helper.provider_human_name(provider) }

    UserAccount.providers.keys.each do |account_provider|
      context "when provider is #{account_provider}" do
        let(:provider) { account_provider }

        it 'returns human mame' do
          expect(provider_human_name).to be_an_instance_of(String)
        end
      end
    end
  end
end
