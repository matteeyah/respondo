# frozen_string_literal: true

RSpec.describe Brand, type: :model do
  let(:brand) { FactoryBot.create(:brand) }

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:external_uid) }
    it { is_expected.to validate_presence_of(:screen_name) }

    it do
      FactoryBot.create(:brand)
      is_expected.to validate_uniqueness_of(:external_uid)
    end
  end

  describe 'Relations' do
    it { is_expected.to have_many(:users) }
    it { is_expected.to have_many(:tickets) }
  end

  describe '.from_omniauth' do
    subject(:from_omniauth) { described_class.from_omniauth(auth_hash, user) }

    let(:auth_hash) { JSON.parse(file_fixture('twitter_oauth_hash.json').read, object_class: OpenStruct) }
    let(:user) { FactoryBot.build(:user) }

    context 'when there is no matching brand' do
      it 'creates a brand' do
        expect { from_omniauth }.to change { described_class.count }.from(0).to(1)
        expect(from_omniauth).to be_persisted
      end

      it 'creats a brand entity with correct info' do
        expect(from_omniauth).to have_attributes(external_uid: auth_hash.uid, screen_name: auth_hash.info.nickname)
      end

      it 'assigns the initial user' do
        expect(from_omniauth.users).to contain_exactly(user)
      end
    end

    context 'when there is a matching brand' do
      let!(:brand) { FactoryBot.create(:brand, external_uid: auth_hash.uid) }

      it 'returns the matching brand' do
        expect(from_omniauth).to eq(brand)
      end

      it 'does not created new brand entities' do
        expect { from_omniauth }.not_to change { described_class.count }.from(1)
      end
    end
  end

  describe '#new_mentions' do
    subject(:new_mentions) { brand.new_mentions }

    let(:twitter_client) { double('Twitter') }

    before do
      allow(brand).to receive(:last_ticket_id).and_return(1)
      allow(brand).to receive(:twitter).and_return(twitter_client)
    end

    it 'queries the twitter client' do
      expect(twitter_client).to receive(:mentions_timeline).with(since: 1)

      new_mentions
    end
  end

  describe '#twitter' do
    subject(:twitter) { brand.twitter }

    it { is_expected.to be_an_instance_of(Clients::Twitter) }
  end
end
