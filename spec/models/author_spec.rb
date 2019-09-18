# frozen_string_literal: true

RSpec.describe Author, type: :model do
  describe 'Validations' do
    subject(:author) { FactoryBot.create(:author) }

    it { is_expected.to validate_presence_of(:external_uid) }
    it { is_expected.to validate_presence_of(:username) }
    it { is_expected.to validate_presence_of(:provider) }

    it { is_expected.to validate_uniqueness_of(:external_uid).scoped_to(:provider) }
  end

  it { is_expected.to define_enum_for(:provider).with_values(%i[twitter google_oauth2]) }

  describe 'Relations' do
    it { is_expected.to have_many(:tickets).dependent(:restrict_with_error) }
  end

  describe '.from_twitter_user' do
    subject(:from_twitter_user) { described_class.from_twitter_user(twitter_user) }

    let(:twitter_user) { instance_double('Twitter::User', id: '1', screen_name: 'helloworld') }

    context 'when there is no matching author' do
      it 'creates a new author' do
        expect { from_twitter_user }.to change(described_class, :count).from(0).to(1)
      end

      it 'returns a new author' do
        expect(from_twitter_user).to be_instance_of(described_class)
      end

      it 'builds an author entity with correct information' do
        expect(from_twitter_user).to have_attributes(external_uid: twitter_user.id, username: twitter_user.screen_name)
      end

      it 'persists the new author' do
        expect(from_twitter_user).to be_persisted
      end
    end

    context 'when author exists' do
      let!(:author) { FactoryBot.create(:author, external_uid: twitter_user.id, provider: 'twitter', username: 'username') }

      it 'returns the matching author' do
        expect(from_twitter_user).to eq(author)
      end

      it 'does not create new author entities' do
        expect { from_twitter_user }.not_to change(described_class, :count).from(1)
      end

      it 'does not change author username' do
        expect { from_twitter_user }.not_to change { author.reload.username }.from('username')
      end
    end
  end
end
