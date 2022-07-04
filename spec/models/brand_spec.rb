# frozen_string_literal: true

require './spec/support/has_accounts_examples'

RSpec.describe Brand, type: :model do
  describe 'Validations' do
    subject(:brand) { create(:brand) }

    it { is_expected.to validate_presence_of(:screen_name) }
    it { is_expected.to allow_value('example.com').for(:domain) }
    it { is_expected.not_to allow_value('not!adomain.com').for(:domain) }
  end

  describe 'Relations' do
    it { is_expected.to have_many(:users).dependent(:nullify) }
    it { is_expected.to have_many(:accounts).dependent(:destroy) }
    it { is_expected.to have_many(:tickets).dependent(:restrict_with_error) }
  end

  describe 'Callbacks' do
    describe '#before_add' do
      subject(:add_user) { brand.users << create(:user) }

      let(:brand) { create(:brand) }
      let(:subscription) { instance_spy(Subscription) }

      before do
        allow(brand).to receive(:subscription).and_return(subscription)
      end

      it 'increments subscription quantity' do
        add_user

        expect(subscription).to have_received(:change_quantity).with(1)
      end
    end

    describe '#before_remove' do
      subject(:remove_user) { brand.users.delete(brand.users.first) }

      let(:brand) { create(:brand) }
      let(:subscription) { instance_spy(Subscription) }

      before do
        allow(brand).to receive(:subscription).and_return(subscription)

        create_list(:user, 2, brand:)
      end

      it 'decrements subscription quantity' do
        remove_user

        expect(subscription).to have_received(:change_quantity).with(1)
      end
    end
  end

  describe '#client_for_provider' do
    subject(:client_for_provider) { brand.client_for_provider(provider) }

    let(:brand) { create(:brand) }

    BrandAccount.providers.each_key do |provider_name|
      context "when provider is #{provider_name}" do
        let(:provider) { provider_name }

        context 'when account for provider exists' do
          let!(:account) { create(:brand_account, brand:, provider: provider_name) }

          it { is_expected.to be_an_instance_of(account.client.class) }
        end

        context 'when account for provider does not exist' do
          it { is_expected.to be_nil }
        end
      end
    end
  end

  it_behaves_like 'has_accounts'
end
