# frozen_string_literal: true

require './spec/concerns/with_descendants_spec'
require './spec/concerns/ticket/from_omniauth_spec'

RSpec.describe Ticket do
  describe 'Validations' do
    subject(:ticket) { create(:internal_ticket).base_ticket }

    it { is_expected.to validate_presence_of(:external_uid) }
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_uniqueness_of(:external_uid).scoped_to(:ticketable_type, :brand_id) }

    describe '#parent_in_brand' do
      context 'when parent does not exist' do
        it 'does not invalidate the ticket' do
          expect(ticket).to be_valid
        end
      end

      context 'when parent is in brand' do
        before do
          ticket.parent = create(:internal_ticket, brand: ticket.brand).base_ticket
        end

        it 'does not invalidate the ticket' do
          expect(ticket).to be_valid
        end
      end

      context 'when parent is not in brand' do
        before do
          ticket.parent = create(:internal_ticket).base_ticket
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

  describe 'Relations' do
    it { is_expected.to belong_to(:author) }
    it { is_expected.to belong_to(:brand) }
    it { is_expected.to belong_to(:creator).optional }
    it { is_expected.to belong_to(:parent).optional }
    it { is_expected.to have_many(:replies).dependent(:destroy) }
    it { is_expected.to have_many(:internal_notes).dependent(:destroy) }
  end

  describe '.root' do
    subject(:root) { described_class.root }

    let(:parentless_ticket) { create(:internal_ticket).base_ticket }

    before do
      create(:internal_ticket, parent: parentless_ticket, brand: parentless_ticket.brand)
    end

    it 'only returns parentless tickets' do
      expect(root).to contain_exactly(parentless_ticket)
    end
  end

  it_behaves_like 'with_descendants' do
    let!(:root_model) { create(:internal_ticket).base_ticket }
    let!(:second_root_model) { create(:internal_ticket).base_ticket }

    # These are used in the shared examples
    let!(:child_model) do # rubocop:disable RSpec/LetSetup
      create(:internal_ticket, parent: root_model, brand: root_model.brand).base_ticket
    end
    let!(:second_child_model) do # rubocop:disable RSpec/LetSetup
      create(:internal_ticket, parent: second_root_model, brand: second_root_model.brand).base_ticket
    end
  end

  it_behaves_like 'from_omniauth'

  describe '#respond_as' do
    subject(:respond_as) { ticket.respond_as(user, 'response') }

    let(:ticket) { create(:external_ticket).base_ticket }
    let(:user) { create(:user) }
    let(:client_spy) { instance_spy(Clients::Client, reply: response_body) }

    let(:response_body) do
      JSON.parse(file_fixture('external_post_hash.json').read)
        .merge(parent_uid: ticket.external_uid).deep_symbolize_keys
    end

    before do
      allow(ticket).to receive(:client).and_return(client_spy)
    end

    it 'creates a response ticket' do
      expect { respond_as }.to change(described_class, :count).from(1).to(2)
    end
  end
end
