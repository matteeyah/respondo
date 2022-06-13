# frozen_string_literal: true

RSpec.describe TicketsQuery, type: :query do
  let(:query) { described_class.new(Ticket.all, params) }

  describe '#call' do
    subject(:call) { query.call }

    context 'when filtering by status' do
      context 'when status is specified' do
        let(:params) { { status: 'solved' } }

        let!(:hit) { create(:internal_ticket, status: 'solved').base_ticket }
        let!(:miss) { create(:internal_ticket, status: 'open').base_ticket }

        it 'searches by ticket status' do
          expect(call).to include(hit)
        end

        it 'does not include misses' do
          expect(call).not_to include(miss)
        end
      end

      context 'when status is not specified' do
        let(:params) { { status: '' } }

        let!(:hit) { create(:internal_ticket, status: 'open').base_ticket }
        let!(:miss) { create(:internal_ticket, status: 'solved').base_ticket }

        it 'searches by ticket status' do
          expect(call).to include(hit)
        end

        it 'does not include misses' do
          expect(call).not_to include(miss)
        end
      end
    end

    context 'when filtering by query' do
      let(:params) { { query: 'hello_world' } }
      let(:author) { create(:author, username: 'hello_world') }
      let!(:author_hit) { create(:internal_ticket, author:).base_ticket }
      let!(:content_hit) { create(:internal_ticket, content: 'hello_world').base_ticket }
      let!(:miss) { create(:internal_ticket).base_ticket }

      it 'searches by author name' do
        expect(call).to include(author_hit)
      end

      it 'searches by ticket content' do
        expect(call).to include(content_hit)
      end

      it 'does not include misses' do
        expect(call).not_to include(miss)
      end
    end
  end
end
