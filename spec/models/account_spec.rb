# frozen_string_literal: true

RSpec.describe Account, type: :model do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:external_uid) }
    it { is_expected.to validate_presence_of(:email) }
  end

  describe 'Relations' do
    it { is_expected.to belong_to(:user) }
  end

  it { is_expected.to define_enum_for(:provider).with_values(%i[twitter google_oauth2]) }

  describe '.from_omniauth' do
    let(:auth_hash) { JSON.parse(file_fixture('twitter_brand_oauth_hash.json').read, object_class: OpenStruct) }

    subject(:from_omniauth) { Account.from_omniauth(auth_hash) }

    context 'when there is no matching account' do
      it 'initializes an account' do
        expect(from_omniauth).to be_an_instance_of(Account)
      end

      it 'creats a brand entity with correct info' do
        expect(from_omniauth).to have_attributes(external_uid: auth_hash.uid, email: auth_hash.info.email)
      end
    end

    context 'when there is a matching account' do
      let!(:account) { FactoryBot.create(:account, external_uid: auth_hash.uid, provider: auth_hash.provider) }

      it 'returns the matching account' do
        expect(from_omniauth).to eq(account)
      end
    end
  end

  describe '#client' do
    let(:account) { FactoryBot.build(:account) }

    subject(:client) { account.client }

    context 'when provider is twitter' do
      before do
        account.provider = 'twitter'
      end

      it { is_expected.to be_an_instance_of(Twitter::REST::Client) }
    end

    context 'when provider is not supported' do
      before do
        account.provider = 'google_oauth2'
      end

      it { is_expected.to eq(nil) }
    end
  end
end
