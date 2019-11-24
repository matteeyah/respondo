# frozen_string_literal: true

RSpec.describe Brand, type: :model do
  describe 'Validations' do
    subject(:brand) { FactoryBot.create(:brand) }

    it { is_expected.to validate_presence_of(:screen_name) }
  end

  describe 'Relations' do
    it { is_expected.to have_many(:users).dependent(:nullify) }
    it { is_expected.to have_many(:brand_accounts).dependent(:destroy) }
    it { is_expected.to have_many(:tickets).dependent(:restrict_with_error) }

    BrandAccount.providers.keys.each do |provider|
      it { is_expected.to have_one(:"#{provider}_account") }
    end
  end

  describe '.search' do
    subject(:search) { described_class.search('hello_world') }

    let!(:hit) { FactoryBot.create(:brand, screen_name: 'hello_world') }
    let!(:miss) { FactoryBot.create(:brand) }

    it 'includes search hits' do
      expect(search).to include(hit)
    end

    it 'does not include misses' do
      expect(search).not_to include(miss)
    end
  end

  describe '#account_for_provider?' do
    subject(:account_for_provider?) { brand.account_for_provider?(provider) }

    let(:brand) { FactoryBot.create(:brand) }

    BrandAccount.providers.keys.each do |provider_name|
      context "when provider is #{provider_name}" do
        let(:provider) { provider_name }

        context 'when account for provider exists' do
          before do
            FactoryBot.create(:brand_account, brand: brand, provider: provider)
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
    subject(:client_for_provider) { brand.client_for_provider(provider) }

    let(:brand) { FactoryBot.create(:brand) }

    BrandAccount.providers.keys.each do |provider_name|
      context "when provider is #{provider_name}" do
        let(:provider) { provider_name }

        context 'when account for provider exists' do
          let!(:account) { FactoryBot.create(:brand_account, brand: brand, provider: provider) }

          it { is_expected.to be_an_instance_of(account.client.class) }
        end

        context 'when account for provider does not exist' do
          it { is_expected.to eq(nil) }
        end
      end
    end
  end
end
