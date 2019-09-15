# frozen_string_literal: true

RSpec.describe Ticket, type: :model do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:external_uid) }
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_presence_of(:provider) }

    it do
      FactoryBot.create(:ticket)
      is_expected.to validate_uniqueness_of(:external_uid).scoped_to(:provider, :brand_id)
    end
  end

  describe 'Relations' do
    it { is_expected.to belong_to(:author) }
    it { is_expected.to belong_to(:brand) }
    it { is_expected.to belong_to(:parent).optional }
    it { is_expected.to have_many(:replies) }
  end

  describe 'Callbacks' do
    describe 'before_save' do
      subject(:execute_callback) { parent.run_callbacks :save }

      let(:parent) { FactoryBot.create(:ticket, status: :open) }
      let(:reply) { FactoryBot.create(:ticket, status: :open, parent: parent) }
      let(:nested_reply) { FactoryBot.create(:ticket, status: :open, parent: reply) }

      context 'when status changes' do
        it 'cascades change to replies' do
          parent.status = 'solved'

          expect { execute_callback }
            .to change { reply.reload.status }.from('open').to('solved')
            .and change { nested_reply.reload.status }.from('open').to('solved')
        end
      end

      context 'when status does not change' do
        it 'does not cascade change to replies' do
          parent.content = 'hello world'

          expect { execute_callback }.not_to change { reply.reload.status }.from('open')
        end
      end
    end
  end

  describe '.root' do
    subject(:root) { described_class.root }

    let(:parentless_ticket) { FactoryBot.create(:ticket) }
    let!(:child_ticket) { FactoryBot.create(:ticket, parent: parentless_ticket) }

    it 'only returns parentless tickets' do
      expect(root).to contain_exactly(parentless_ticket)
    end
  end

  describe '.from_tweet' do
    subject(:from_tweet) { described_class.from_tweet(tweet, brand) }

    let(:brand) { FactoryBot.create(:brand) }

    let(:tweet) do
      OpenStruct.new(
        id: '2',
        text: 'helloworld',
        user: 'does not matter',
        in_reply_to_tweet_id: '1'
      )
    end

    before do
      allow(Author).to receive(:from_twitter_user).and_return(FactoryBot.create(:author))
    end

    context 'when ticket exists' do
      let!(:ticket) { FactoryBot.create(:ticket, external_uid: '2', provider: 'twitter', brand: brand) }

      it 'returns the existing ticket' do
        expect(from_tweet).to eq(ticket)
      end
    end

    context 'when ticket does not exist' do
      it 'creates a new ticket' do
        expect { from_tweet }.to change { described_class.count }.from(0).to(1)
      end

      it 'returns a new ticket' do
        expect(from_tweet).to be_instance_of(described_class)
        expect(from_tweet).to have_attributes(external_uid: '2', content: 'helloworld', brand: brand)
      end

      context 'when parent exists' do
        let!(:parent) { FactoryBot.create(:ticket, external_uid: '1') }

        it 'sets the ticket parent' do
          expect(from_tweet.parent).to eq(parent)
        end
      end
    end
  end
end
