# frozen_string_literal: true

RSpec.describe User, type: :model do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'Relations' do
    it { is_expected.to belong_to(:brand).optional }
    it { is_expected.to have_many(:accounts).dependent(:destroy) }

    Account.providers.keys.each do |provider|
      it { is_expected.to have_one(:"#{provider}_account") }
    end
  end

  describe '#account_for_provider?' do
    subject(:account_for_provider?) { user.account_for_provider?(provider) }

    let(:user) { FactoryBot.create(:user) }

    Account.providers.keys.each do |provider_name|
      context "when provider is #{provider_name}" do
        let(:provider) { provider_name }

        context 'when account for provider exists' do
          before do
            FactoryBot.create(:account, user: user, provider: provider)
          end

          it { is_expected.to eq(true) }
        end

        context 'when account for provider does not exist' do
          it { is_expected.to eq(false) }
        end
      end
    end
  end

  describe '#client_for_provider' do
    subject(:client_for_provider) { user.client_for_provider(provider) }

    let(:user) { FactoryBot.create(:user) }

    Account.providers.keys.each do |provider_name|
      context "when provider is #{provider_name}" do
        let(:provider) { provider_name }

        context 'when account for provider exists' do
          let!(:account) { FactoryBot.create(:account, user: user, provider: provider) }

          it { is_expected.to be_an_instance_of(account.client.class) }
        end

        context 'when account for provider does not exist' do
          it { is_expected.to eq(nil) }
        end
      end
    end
  end
end
