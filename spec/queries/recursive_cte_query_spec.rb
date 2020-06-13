# frozen_string_literal: true

RSpec.describe RecursiveCteQuery, type: :query do
  let(:query) { described_class.new(Ticket.all, params) }

  describe '#call' do
    subject(:call) { query.call }

    let(:params) { { model_column: :parent_id, recursive_cte_column: :id } }
    let!(:root) { FactoryBot.create(:internal_ticket).base_ticket }
    let!(:descendant) { FactoryBot.create(:internal_ticket, brand: root.brand, parent: root).base_ticket }
    let!(:nested_descendant) { FactoryBot.create(:internal_ticket, brand: root.brand, parent: descendant).base_ticket }

    it 'returns self and all descendants' do
      expect(call).to include(root, descendant, nested_descendant)
    end
  end
end
