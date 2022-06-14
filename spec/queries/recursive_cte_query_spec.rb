# frozen_string_literal: true

RSpec.describe RecursiveCteQuery, type: :query do
  let(:query) { described_class.new(Ticket.all, params) }

  describe '#call' do
    subject(:call) { query.call }

    let(:params) { { model_column: :parent_id, recursive_cte_column: :id } }
    let!(:root) { create(:internal_ticket).base_ticket }
    let!(:descendant) { create(:internal_ticket, brand: root.brand, parent: root).base_ticket }
    let!(:nested_descendant) { create(:internal_ticket, brand: root.brand, parent: descendant).base_ticket }

    let(:expected_sql) do
      <<~SQL.squish
        SELECT "tickets".* FROM "tickets" WHERE "tickets"."id" IN
          (WITH RECURSIVE "recursive_cte" AS (
            SELECT "tickets".* FROM "tickets" WHERE "tickets"."id" IN (SELECT "tickets"."id" FROM "tickets")
            UNION ALL
            SELECT "tickets".* FROM "tickets" INNER JOIN "recursive_cte" ON "tickets"."parent_id" = "recursive_cte"."id"
          ) SELECT "recursive_cte"."id" FROM "recursive_cte")
      SQL
    end

    it 'returns self and all descendants' do
      expect(call).to include(root, descendant, nested_descendant)
    end

    it 'forms the right sql' do
      expect(call.to_sql).to eq(expected_sql)
    end
  end
end
