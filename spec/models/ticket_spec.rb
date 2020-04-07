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
  it { is_expected.to define_enum_for(:provider).with_values(%i[external twitter disqus]) }

  describe 'Relations' do
    it { is_expected.to belong_to(:author) }
    it { is_expected.to belong_to(:brand) }
    it { is_expected.to belong_to(:user).optional }
    it { is_expected.to belong_to(:parent).optional }
    it { is_expected.to have_many(:replies).dependent(:destroy) }
    it { is_expected.to have_many(:internal_notes).dependent(:restrict_with_error) }
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

  describe '.from_ methods' do
    shared_examples 'from method' do
      context 'when user is not specified' do
        let(:user) { nil }

        it 'creates a new ticket' do
          expect { subject }.to change(described_class, :count).from(0).to(1)
        end

        it 'returns a new ticket' do
          expect(subject).to be_instance_of(described_class)
        end

        it 'persists the new ticket' do
          expect(subject).to be_persisted
        end

        it 'builds a ticket with correct information' do
          expect(subject).to have_attributes(expected_attributes.merge(parent: nil))
        end

        context 'when parent exists' do
          let!(:parent) { FactoryBot.create(:ticket, external_uid: parent_id, provider: expected_attributes[:provider], brand: brand) }

          it 'assigns the parent to the ticket' do
            expect(subject).to have_attributes(parent: parent)
          end
        end
      end

      context 'when the user is specified' do
        let(:user) { FactoryBot.create(:user) }

        it 'creates a new ticket' do
          expect { subject }.to change(described_class, :count).from(0).to(1)
        end

        it 'returns a new ticket' do
          expect(subject).to be_instance_of(described_class)
        end

        it 'persists the new ticket' do
          expect(subject).to be_persisted
        end

        it 'builds a ticket with correct information' do
          expect(subject).to have_attributes(expected_attributes.merge(parent: nil))
        end

        context 'when parent exists' do
          let!(:parent) { FactoryBot.create(:ticket, external_uid: parent_id, provider: expected_attributes[:provider], brand: brand) }

          it 'assigns the parent to the ticket' do
            expect(subject).to have_attributes(parent: parent)
          end
        end
      end
    end

    describe '.from_tweet!' do
      subject(:from_tweet!) { described_class.from_tweet!(tweet, brand, user) }

      let(:brand) { FactoryBot.create(:brand) }
      let(:author) { FactoryBot.create(:author) }

      let(:tweet) do
        instance_double(Twitter::Tweet,
                        JSON.parse(file_fixture('twitter_post_hash.json').read).deep_symbolize_keys)
      end

      before do
        allow(Author).to receive(:from_twitter_user!).with(tweet.user).and_return(author)
      end

      it_behaves_like 'from method' do
        let(:parent_id) { tweet.in_reply_to_tweet_id }

        let(:expected_attributes) do
          {
            external_uid: tweet.id, provider: 'twitter', content: tweet.attrs[:full_text],
            response_url: nil, custom_provider: nil, brand: brand, author: author, user: user
          }
        end
      end
    end

    describe '.from_disqus_post!' do
      subject(:from_disqus_post!) { described_class.from_disqus_post!(disqus_post, brand, user) }

      let(:brand) { FactoryBot.create(:brand) }
      let(:author) { FactoryBot.create(:author) }

      let(:disqus_post) { JSON.parse(file_fixture('disqus_post_hash.json').read).deep_symbolize_keys }

      before do
        allow(Author).to receive(:from_disqus_user!).with(disqus_post[:author]).and_return(author)
      end

      it_behaves_like 'from method' do
        let(:parent_id) { disqus_post[:parent] }

        let(:expected_attributes) do
          {
            external_uid: disqus_post[:id], provider: 'disqus', content: disqus_post[:raw_message],
            response_url: nil, custom_provider: nil, brand: brand, author: author, user: user
          }
        end
      end
    end

    describe '.from_external_ticket!' do
      subject(:from_external_ticket!) { described_class.from_external_ticket!(external_ticket_json, brand, user) }

      let(:brand) { FactoryBot.create(:brand) }
      let(:author) { FactoryBot.create(:author) }

      let(:external_ticket_json) { JSON.parse(file_fixture('external_post_hash.json').read).deep_symbolize_keys }

      before do
        allow(Author).to receive(:from_external_author!).with(external_ticket_json[:author]).and_return(author)
      end

      it_behaves_like 'from method' do
        let(:parent_id) { external_ticket_json[:parent_uid] }

        let(:expected_attributes) do
          {
            external_uid: external_ticket_json[:external_uid], provider: 'external',
            content: external_ticket_json[:content], response_url: 'https://response_url.com',
            brand: brand, author: author, user: user
          }
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

  describe '#actual_provider' do
    subject(:actual_provider) { ticket.actual_provider }

    let(:ticket) { FactoryBot.create(:ticket) }

    context 'when ticket has custom provider' do
      before do
        ticket.custom_provider = 'hacker_news'
      end

      it 'uses custom provider' do
        expect(actual_provider).to eq('hacker_news')
      end
    end

    context 'when ticket does not have custom provider' do
      before do
        ticket.custom_provider = nil
      end

      it 'uses ticket provider' do
        expect(actual_provider).to eq(ticket.provider)
      end
    end
  end
end
