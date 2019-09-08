# frozen_string_literal: true

RSpec.describe Author, type: :model do
  it { is_expected.to have_many(:tickets) }

  describe '.from_twitter_user' do
    let(:twitter_user) { OpenStruct.new(id: '1', screen_name: 'helloworld') }

    subject { described_class.from_twitter_user(twitter_user) }

    context 'when author exists' do
      let!(:author) { FactoryBot.create(:author, external_uid: '1') }

      it 'returns the existing author' do
        expect(subject).to eq(author)
      end
    end

    context 'when author does not exist' do
      it 'creates a new author' do
        expect { subject }.to change { Author.count }.from(0).to(1)
      end

      it 'returns a new author' do
        expect(subject).to be_instance_of(Author)
        expect(subject).to have_attributes(external_uid: '1', username: 'helloworld')
      end
    end
  end
end
