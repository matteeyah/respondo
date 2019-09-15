# frozen_string_literal: true

RSpec.describe Author, type: :model do
  describe 'Validations' do
    subject(:author) { FactoryBot.create(:author) }

    it { is_expected.to validate_presence_of(:external_uid) }
    it { is_expected.to validate_presence_of(:username) }
    it { is_expected.to validate_presence_of(:provider) }
    it { is_expected.to validate_uniqueness_of(:external_uid).scoped_to(:provider) }
  end

  describe 'Relations' do
    it { is_expected.to have_many(:tickets) }
  end

  describe '.from_twitter_user' do
    subject(:from_twitter_user) { described_class.from_twitter_user(twitter_user) }

    let(:twitter_user) { OpenStruct.new(id: '1', screen_name: 'helloworld') }

    context 'when author exists' do
      let!(:author) { FactoryBot.create(:author, external_uid: '1') }

      it 'returns the existing author' do
        expect(from_twitter_user).to eq(author)
      end
    end

    context 'when author does not exist' do
      it 'creates a new author' do
        expect { from_twitter_user }.to change(described_class, :count).from(0).to(1)
      end

      it 'returns a new author' do
        expect(from_twitter_user).to be_instance_of(described_class)
      end

      it 'returns an author with matching attributes' do
        expect(from_twitter_user).to have_attributes(external_uid: '1', username: 'helloworld')
      end
    end
  end
end
