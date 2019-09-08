# frozen_string_literal: true

RSpec.describe Brand, type: :model do
  it { is_expected.to have_many(:users) }
  it { is_expected.to have_many(:tickets) }

  describe '.from_omniauth' do
    let(:auth_hash) { JSON.parse(file_fixture('twitter_brand_oauth_hash.json').read, object_class: OpenStruct) }
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

  describe '#threaded_mentions' do
    let(:parent_tweet) { Brand::ThreadedTweet.new(1, nil, 'matteeyah', 'test', []) }
    let(:child_tweet) { Brand::ThreadedTweet.new(2, 1, 'matteeyah', 'second_test', []) }
    let(:brand) { FactoryBot.build(:brand) }
    let(:tweets) { [parent_tweet, child_tweet] }

    subject { brand.threaded_mentions }

    before do
      allow(brand).to receive(:mentions).and_return(tweets)
    end

    it 'threads the tweets' do
      expect(subject.count).to eq(1)
      expect(subject.first.replies).to contain_exactly(child_tweet)
    end

    context 'when there is skip threading' do
      let(:skip_parent) { Brand::ThreadedTweet.new(3, 5, 'matteeyah', 'third_test', []) }
      let(:skip_child) { Brand::ThreadedTweet.new(4, 3, 'matteeyah', 'fourth_test', []) }

      let(:tweets) { [parent_tweet, child_tweet, skip_parent, skip_child] }

      it 'threads the tweets' do
        expect(subject.count).to eq(2)
        expect(subject.first.replies).to contain_exactly(child_tweet)
        expect(subject.second.replies).to contain_exactly(skip_child)
      end
    end
  end
end
