# frozen_string_literal: true

require './spec/support/has_accounts_examples'

RSpec.describe Brand, type: :model do
  describe 'Validations' do
    subject(:brand) { FactoryBot.create(:brand) }

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
      subject(:add_user) { brand.users << FactoryBot.create(:user) }

      let(:brand) { FactoryBot.create(:brand) }
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

      let(:brand) { FactoryBot.create(:brand) }
      let(:subscription) { instance_spy(Subscription) }

      before do
        allow(brand).to receive(:subscription).and_return(subscription)

        FactoryBot.create_list(:user, 2, brand: brand)
      end

      it 'decrements subscription quantity' do
        remove_user

        expect(subscription).to have_received(:change_quantity).with(1)
      end
    end
  end

  it_behaves_like 'has_accounts'
end
