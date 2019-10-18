# frozen_string_literal: true

RSpec.describe Ticket, type: :model do
  describe 'Validations' do
    subject(:ticket) { FactoryBot.create(:ticket) }

    it { is_expected.to validate_presence_of(:external_uid) }
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_presence_of(:provider) }
    it { is_expected.to validate_uniqueness_of(:external_uid).scoped_to(:provider, :brand_id) }
  end

  it { is_expected.to define_enum_for(:status).with_values(%i[open solved]) }
  it { is_expected.to define_enum_for(:provider).with_values([:twitter]) }

  describe 'Relations' do
    it { is_expected.to belong_to(:author) }
    it { is_expected.to belong_to(:brand) }
    it { is_expected.to belong_to(:parent).optional }
    it { is_expected.to have_many(:replies).dependent(:destroy) }
  end

  describe 'Callbacks' do
    describe 'cascade_status' do
      subject(:execute_callback) { parent.run_callbacks(:save) }

      let(:parent) { FactoryBot.create(:ticket, status: :open) }
      let(:reply) { FactoryBot.create(:ticket, status: :open, parent: parent) }
      let(:nested_reply) { FactoryBot.create(:ticket, status: :open, parent: reply) }

      context 'when status changes' do
        before do
          parent.status = 'solved'
        end

        it 'cascades change to replies' do
          expect { execute_callback }
            .to change { reply.reload.status }.from('open').to('solved')
            .and change { nested_reply.reload.status }.from('open').to('solved')
        end
      end

      context 'when status does not change' do
        before do
          parent.content = 'hello world'
        end

        it 'does not cascade change to replies' do
          expect { execute_callback }.not_to change { reply.reload.status }.from('open')
        end
      end
    end
  end

  describe '.root' do
    subject(:root) { described_class.root }

    let(:parentless_ticket) { FactoryBot.create(:ticket) }

    before do
      FactoryBot.create(:ticket, parent: parentless_ticket)
    end

    it 'only returns parentless tickets' do
      expect(root).to contain_exactly(parentless_ticket)
    end
  end

  describe '.from_tweet' do
    subject(:from_tweet) { described_class.from_tweet(tweet, brand) }

    let(:brand) { FactoryBot.create(:brand) }
    let(:author) { FactoryBot.create(:author) }

    let(:tweet) do
      instance_double('Twitter::Tweet',
                      id: '2',
                      text: 'helloworld',
                      user: 'does not matter',
                      in_reply_to_tweet_id: '1')
    end

    before do
      allow(Author).to receive(:from_twitter_user).with(tweet.user).and_return(author)
    end

    context 'when parent does not exist' do
      it 'creates a new ticket' do
        expect { from_tweet }.to change(described_class, :count).from(0).to(1)
      end

      it 'returns a new ticket' do
        expect(from_tweet).to be_instance_of(described_class)
      end

      it 'builds a ticket with correct information' do
        expect(from_tweet).to have_attributes(
          external_uid: tweet.id, provider: 'twitter',
          content: tweet.text,
          brand: brand, parent: nil, author: author
        )
      end

      it 'persists the new ticket' do
        expect(from_tweet).to be_persisted
      end
    end

    context 'when parent exists' do
      let!(:parent) { FactoryBot.create(:ticket, external_uid: tweet.in_reply_to_tweet_id) }

      it 'creates a new ticket' do
        expect { from_tweet }.to change(described_class, :count).from(1).to(2)
      end

      it 'returns a new ticket' do
        expect(from_tweet).to be_instance_of(described_class)
      end

      it 'builds a ticket with correct information' do
        expect(from_tweet).to have_attributes(
          external_uid: tweet.id, provider: 'twitter',
          content: tweet.text,
          brand: brand, parent: parent, author: author
        )
      end

      it 'persists the new ticket' do
        expect(from_tweet).to be_persisted
      end
    end
  end

  describe '.with_descendants_hash' do
    subject(:with_descendants_hash) { described_class.root.with_descendants_hash }

    let(:first_root_ticket) { FactoryBot.create(:ticket) }
    let(:second_root_ticket) { FactoryBot.create(:ticket) }
    let!(:first_child_ticket) { FactoryBot.create(:ticket, parent: first_root_ticket) }
    let!(:second_child_ticket) { FactoryBot.create(:ticket, parent: second_root_ticket) }

    it 'returns tickets in hash format' do
      expect(with_descendants_hash).to be_an_instance_of(Hash)
    end

    it 'maintains the ticket structure' do
      expect(with_descendants_hash).to include(
        first_root_ticket => { first_child_ticket => {} },
        second_root_ticket => { second_child_ticket => {} }
      )
    end
  end
end
