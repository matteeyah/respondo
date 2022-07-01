# frozen_string_literal: true

RSpec.describe Author, type: :model do
  describe 'Validations' do
    subject(:author) { create(:author) }

    it { is_expected.to validate_presence_of(:external_uid) }
    it { is_expected.to validate_presence_of(:username) }
    it { is_expected.to validate_presence_of(:provider) }

    it { is_expected.to validate_uniqueness_of(:external_uid).scoped_to(:provider) }
  end

  it { is_expected.to define_enum_for(:provider).with_values(%i[external twitter disqus]) }

  describe 'Relations' do
    it { is_expected.to have_many(:tickets).dependent(:restrict_with_error) }
  end

  describe '.from_twitter_user!' do
    subject(:from_twitter_user!) { described_class.from_twitter_user!(twitter_user) }

    let(:twitter_user) { instance_double(Twitter::User, id: '1', screen_name: 'helloworld') }

    context 'when there is no matching author' do
      it 'creates a new author' do
        expect { from_twitter_user! }.to change(described_class, :count).from(0).to(1)
      end

      it 'returns a new author' do
        expect(from_twitter_user!).to be_instance_of(described_class)
      end

      it 'builds an author entity with correct information' do
        expect(from_twitter_user!).to have_attributes(external_uid: twitter_user.id, username: twitter_user.screen_name)
      end

      it 'persists the new author' do
        expect(from_twitter_user!).to be_persisted
      end
    end

    context 'when author exists' do
      let!(:author) { create(:author, external_uid: twitter_user.id, provider: 'twitter') }

      it 'returns the matching author' do
        expect(from_twitter_user!).to eq(author)
      end

      it 'does not create new author entities' do
        expect { from_twitter_user! }.not_to change(described_class, :count).from(1)
      end

      context 'when username does not change' do
        before do
          author.update!(username: twitter_user.screen_name)
        end

        it 'does not update username' do
          expect { from_twitter_user! }.not_to change { author.reload.username }.from(twitter_user.screen_name)
        end
      end

      context 'when username changes' do
        it 'updates username' do
          expect { from_twitter_user! }.to change { author.reload.username }.to(twitter_user.screen_name)
        end
      end
    end
  end

  describe '.from_disqus_user!' do
    subject(:from_disqus_user!) { described_class.from_disqus_user!(disqus_user) }

    let(:disqus_user) { { id: '12321', username: 'helloworld' } }

    context 'when there is no matching author' do
      it 'creates a new author' do
        expect { from_disqus_user! }.to change(described_class, :count).from(0).to(1)
      end

      it 'returns a new author' do
        expect(from_disqus_user!).to be_instance_of(described_class)
      end

      it 'builds an author entity with correct information' do
        expect(from_disqus_user!).to have_attributes(external_uid: disqus_user[:id], username: disqus_user[:username])
      end

      it 'persists the new author' do
        expect(from_disqus_user!).to be_persisted
      end
    end

    context 'when author exists' do
      let!(:author) { create(:author, external_uid: disqus_user[:id], provider: 'disqus') }

      it 'returns the matching author' do
        expect(from_disqus_user!).to eq(author)
      end

      it 'does not create new author entities' do
        expect { from_disqus_user! }.not_to change(described_class, :count).from(1)
      end

      context 'when username does not change' do
        before do
          author.update!(username: disqus_user[:username])
        end

        it 'does not update username' do
          expect { from_disqus_user! }.not_to change { author.reload.username }.from(disqus_user[:username])
        end
      end

      context 'when username changes' do
        it 'updates username' do
          expect { from_disqus_user! }.to change { author.reload.username }.to(disqus_user[:username])
        end
      end
    end
  end

  describe '.from_external_author!' do
    subject(:from_external_author!) { described_class.from_external_author!(external_author_json) }

    let(:external_author_json) do
      {
        external_uid: '123hello321world',
        username: 'best_username'
      }
    end

    context 'when there is no matching author' do
      it 'creates a new author' do
        expect { from_external_author! }.to change(described_class, :count).from(0).to(1)
      end

      it 'returns a new author' do
        expect(from_external_author!).to be_instance_of(described_class)
      end

      it 'builds an author entity with correct information' do
        expect(from_external_author!).to have_attributes(
          external_uid: external_author_json[:external_uid], username: external_author_json[:username]
        )
      end

      it 'persists the new author' do
        expect(from_external_author!).to be_persisted
      end
    end

    context 'when author exists' do
      let!(:author) { create(:author, external_uid: external_author_json[:external_uid], provider: 'external') }

      it 'returns the matching author' do
        expect(from_external_author!).to eq(author)
      end

      it 'does not create new author entities' do
        expect { from_external_author! }.not_to change(described_class, :count).from(1)
      end

      context 'when username does not change' do
        before do
          author.update!(username: external_author_json[:username])
        end

        it 'does not update username' do
          expect { from_external_author! }.not_to change {
                                                    author.reload.username
                                                  }.from(external_author_json[:username])
        end
      end

      context 'when username changes' do
        it 'updates username' do
          expect { from_external_author! }.to change { author.reload.username }.to(external_author_json[:username])
        end
      end
    end
  end

  describe '#external_link' do
    subject(:external_link) { author.external_link }

    let(:author) { create(:author, username: 'helloworld', provider: provider) }

    context 'when provider is twitter' do
      let(:provider) { 'twitter' }

      it { is_expected.to eq('https://twitter.com/helloworld') }
    end

    context 'when provider is not supported' do
      let(:provider) { 'disqus' }

      it { is_expected.to be_nil }
    end
  end
end
