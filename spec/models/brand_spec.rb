# frozen_string_literal: true

RSpec.describe Brand, type: :model do
  describe 'Validations' do
    subject(:brand) { FactoryBot.create(:brand) }

    it { is_expected.to validate_presence_of(:external_uid) }
    it { is_expected.to validate_presence_of(:screen_name) }
    it { is_expected.to validate_uniqueness_of(:external_uid) }
  end

  describe 'Relations' do
    it { is_expected.to have_many(:users).dependent(:nullify) }
    it { is_expected.to have_many(:tickets).dependent(:restrict_with_error) }
  end

  describe '.from_omniauth' do
    subject(:from_omniauth) { described_class.from_omniauth(auth_hash, user) }

    let(:auth_hash) { JSON.parse(file_fixture('twitter_oauth_hash.json').read, object_class: OpenStruct) }
    let(:user) { FactoryBot.build(:user) }

    context 'when there is no matching brand' do
      it 'creates a new brand' do
        expect { from_omniauth }.to change(described_class, :count).from(0).to(1)
      end

      it 'returns a new brand' do
        expect(from_omniauth).to be_an_instance_of(described_class)
      end

      it 'builds a brand entity with correct information' do
        expect(from_omniauth).to have_attributes(
          external_uid: auth_hash.uid, screen_name: auth_hash.info.nickname,
          token: auth_hash.credentials.token, secret: auth_hash.credentials.secret
        )
      end

      it 'assigns the initial user' do
        expect(from_omniauth.users).to contain_exactly(user)
      end

      it 'persists the new brand' do
        expect(from_omniauth).to be_persisted
      end
    end

    context 'when there is a matching brand' do
      let!(:brand) do
        FactoryBot.create(:brand, screen_name: 'helloworld',
                                  external_uid: auth_hash.uid,
                                  token: 'token', secret: 'secret')
      end

      it 'returns the matching brand' do
        expect(from_omniauth).to eq(brand)
      end

      it 'does not create new brand entities' do
        expect { from_omniauth }.not_to change(described_class, :count).from(1)
      end

      it 'does not change brand screen name' do
        expect { from_omniauth }.not_to change { brand.reload.screen_name }.from('helloworld')
      end

      it 'does not change brand token' do
        expect { from_omniauth }.not_to change { brand.reload.token }.from('token')
      end

      it 'does not change brand secret' do
        expect { from_omniauth }.not_to change { brand.reload.secret }.from('secret')
      end

      it 'does not add the initial user' do
        expect(from_omniauth.users).not_to include(user)
      end
    end
  end

  describe '#new_mentions' do
    subject(:new_mentions) { brand.new_mentions }

    let(:brand) { FactoryBot.build(:brand) }
    let(:twitter_client) { instance_spy(Clients::Twitter) }

    before do
      allow(brand).to receive(:twitter).and_return(twitter_client)
    end

    context 'when brand has at least one ticket' do
      before do
        FactoryBot.create(:ticket, brand: brand)
      end

      it 'queries the twitter client with last ticket id' do
        new_mentions

        expect(twitter_client).to have_received(:mentions_timeline).with(since: an_instance_of(String))
      end
    end

    context 'when brand has no tickets' do
      it 'queries the twitter client without last ticket id' do
        new_mentions

        expect(twitter_client).to have_received(:mentions_timeline).with(since: nil)
      end
    end
  end

  describe '#twitter' do
    subject(:twitter) { brand.twitter }

    let(:brand) { FactoryBot.build(:brand) }

    it { is_expected.to be_an_instance_of(Clients::Twitter) }
  end
end
