# frozen_string_literal: true

RSpec.describe Ticket, type: :model do
  describe 'Validations' do
    subject(:ticket) { FactoryBot.create(:ticket) }

    it { is_expected.to validate_presence_of(:external_uid) }
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_presence_of(:provider) }
    it { is_expected.to validate_uniqueness_of(:external_uid).scoped_to(:provider, :brand_id) }

    describe '#parent_in_brand' do
      context 'when parent does not exist' do
        it 'does not invalidate the ticket' do
          expect(ticket).to be_valid
        end
      end

      context 'when parent is in brand' do
        before do
          ticket.parent = FactoryBot.create(:ticket, brand: ticket.brand)
        end

        it 'does not invalidate the ticket' do
          expect(ticket).to be_valid
        end
      end

      context 'when parent is not in brand' do
        before do
          ticket.parent = FactoryBot.create(:ticket)
        end

        it 'invalidates the ticket' do
          expect(ticket).not_to be_valid
        end

        it 'returns parent validation error' do
          ticket.validate

          expect(ticket.errors).to include(:parent)
        end
      end
    end
  end

  it { is_expected.to define_enum_for(:status).with_values(%i[open solved]) }
  it { is_expected.to define_enum_for(:provider).with_values([:twitter]) }

  describe 'Relations' do
    it { is_expected.to belong_to(:author) }
    it { is_expected.to belong_to(:brand) }
    it { is_expected.to belong_to(:user).optional }
    it { is_expected.to belong_to(:parent).optional }
    it { is_expected.to have_many(:replies).dependent(:destroy) }
    it { is_expected.to have_many(:comments).dependent(:restrict_with_error) }
  end

  describe 'State Machine' do
    let(:root) { FactoryBot.create(:ticket, status: status) }
    let(:parent) { FactoryBot.create(:ticket, status: status, parent: root, brand: root.brand) }
    let(:ticket) { FactoryBot.create(:ticket, status: status, parent: parent, brand: root.brand) }
    let(:nested_ticket) { FactoryBot.create(:ticket, status: status, parent: ticket, brand: root.brand) }
    let!(:nested_nested_ticket) { FactoryBot.create(:ticket, status: status, parent: nested_ticket, brand: root.brand) }

    describe 'open' do
      subject(:open_ticket) { ticket.open! }

      let(:status) { :solved }

      it 'cascades change to ancestors' do
        expect { open_ticket }
          .to change { parent.reload.status }.from('solved').to('open')
          .and change { root.reload.status }.from('solved').to('open')
      end

      it 'does not cascade change to descendants' do
        expect { open_ticket }.not_to change { nested_ticket.reload.status }.from('solved')
      end
    end

    describe 'solve' do
      subject(:solve_ticket) { ticket.solve! }

      let(:status) { :open }

      it 'cascades change to descendants' do
        expect { solve_ticket }
          .to change { nested_ticket.reload.status }.from('open').to('solved')
          .and change { nested_nested_ticket.reload.status }.from('open').to('solved')
      end

      it 'does not cascade change ancestors' do
        expect { solve_ticket }.not_to change { parent.reload.status }.from('open')
      end
    end
  end

  describe '.root' do
    subject(:root) { described_class.root }

    let(:parentless_ticket) { FactoryBot.create(:ticket) }

    before do
      FactoryBot.create(:ticket, parent: parentless_ticket, brand: parentless_ticket.brand)
    end

    it 'only returns parentless tickets' do
      expect(root).to contain_exactly(parentless_ticket)
    end
  end

  describe '.search' do
    subject(:search) { described_class.search('hello_world') }

    let!(:author_hit) { FactoryBot.create(:ticket, author: FactoryBot.create(:author, username: 'hello_world')) }
    let!(:content_hit) { FactoryBot.create(:ticket, content: 'hello_world') }
    let!(:miss) { FactoryBot.create(:ticket) }

    it 'searches by author name' do
      expect(search).to include(author_hit)
    end

    it 'searches by ticket content' do
      expect(search).to include(content_hit)
    end

    it 'does not include misses' do
      expect(search).not_to include(miss)
    end
  end

  describe '.from_tweet' do
    subject(:from_tweet) { described_class.from_tweet(tweet, brand, user) }

    let(:brand) { FactoryBot.create(:brand) }
    let(:author) { FactoryBot.create(:author) }

    let(:tweet) do
      instance_double(Twitter::Tweet,
                      id: '2',
                      attrs: { full_text: 'helloworld' },
                      user: 'does not matter',
                      in_reply_to_tweet_id: '1')
    end

    before do
      allow(Author).to receive(:from_twitter_user).with(tweet.user).and_return(author)
    end

    context 'when user is not specified' do
      let(:user) { nil }

      it 'creates a new ticket' do
        expect { from_tweet }.to change(described_class, :count).from(0).to(1)
      end

      it 'returns a new ticket' do
        expect(from_tweet).to be_instance_of(described_class)
      end

      it 'persists the new ticket' do
        expect(from_tweet).to be_persisted
      end

      it 'builds a ticket with correct information' do
        expect(from_tweet).to have_attributes(
          external_uid: tweet.id, provider: 'twitter', content: tweet.attrs[:full_text],
          brand: brand, parent: nil, author: author, user: nil
        )
      end

      context 'when parent exists' do
        let!(:parent) { FactoryBot.create(:ticket, external_uid: tweet.in_reply_to_tweet_id, brand: brand) }

        it 'assigns the parent to the ticket' do
          expect(from_tweet).to have_attributes(parent: parent)
        end
      end
    end

    context 'when the user is specified' do
      let(:user) { FactoryBot.create(:user) }

      it 'creates a new ticket' do
        expect { from_tweet }.to change(described_class, :count).from(0).to(1)
      end

      it 'returns a new ticket' do
        expect(from_tweet).to be_instance_of(described_class)
      end

      it 'persists the new ticket' do
        expect(from_tweet).to be_persisted
      end

      it 'builds a ticket with correct information' do
        expect(from_tweet).to have_attributes(
          external_uid: tweet.id, provider: 'twitter', content: tweet.attrs[:full_text],
          brand: brand, parent: nil, author: author, user: user
        )
      end

      context 'when parent exists' do
        let!(:parent) { FactoryBot.create(:ticket, external_uid: tweet.in_reply_to_tweet_id, brand: brand) }

        it 'assigns the parent to the ticket' do
          expect(from_tweet).to have_attributes(parent: parent)
        end
      end
    end
  end

  describe '.with_descendants_hash' do
    subject(:with_descendants_hash) { described_class.root.with_descendants_hash }

    let(:first_root_ticket) { FactoryBot.create(:ticket) }
    let(:second_root_ticket) { FactoryBot.create(:ticket) }
    let!(:first_child_ticket) { FactoryBot.create(:ticket, parent: first_root_ticket, brand: first_root_ticket.brand) }
    let!(:second_child_ticket) { FactoryBot.create(:ticket, parent: second_root_ticket, brand: second_root_ticket.brand) }

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
