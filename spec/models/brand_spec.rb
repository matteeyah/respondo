# frozen_string_literal: true

RSpec.describe Brand, type: :model do
  let(:brand) { FactoryBot.create(:brand) }

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:external_uid) }
    it { is_expected.to validate_presence_of(:screen_name) }
  end

  describe 'Relations' do
    it { is_expected.to have_many(:users) }
    it { is_expected.to have_many(:tickets) }
  end

  describe '.from_omniauth' do
    let(:auth_hash) { JSON.parse(file_fixture('twitter_oauth_hash.json').read, object_class: OpenStruct) }
    let(:user) { FactoryBot.build(:user) }

    subject { Brand.from_omniauth(auth_hash, user) }

    context 'when there is no matching brand' do
      it 'creates a brand' do
        expect { subject }.to change { Brand.count }.from(0).to(1)
        expect(subject).to be_persisted
      end

      it 'creats a brand entity with correct info' do
        expect(subject).to have_attributes(external_uid: auth_hash.uid, screen_name: auth_hash.info.nickname)
      end

      it 'assigns the initial user' do
        expect(subject.users).to contain_exactly(user)
      end
    end

    context 'when there is a matching brand' do
      let!(:brand) { FactoryBot.create(:brand, external_uid: auth_hash.uid) }

      it 'returns the matching brand' do
        expect(subject).to eq(brand)
      end

      it 'does not created new brand entities' do
        expect { subject }.not_to change { Brand.count }.from(1)
      end
    end
  end

  describe '#new_mentions' do
    let(:twitter_client) { double('Twitter') }

    subject { brand.new_mentions }

    before do
      allow(brand).to receive(:last_ticket_id).and_return(1)
      allow(brand).to receive(:twitter).and_return(twitter_client)
    end

    it 'queries the twitter client' do
      expect(twitter_client).to receive(:mentions_timeline).with(since: 1)

      subject
    end
  end

  describe '#reply' do
    let(:twitter_client) { double('Twitter') }

    subject { brand.reply('does not matter', 'tweet_id') }

    before do
      allow(brand).to receive(:twitter).and_return(twitter_client)
    end

    it 'queries the twitter client' do
      expect(twitter_client).to receive(:update)
        .with('does not matter', in_reply_to_status_id: 'tweet_id', auto_populate_reply_metadata: true)

      subject
    end
  end
end
