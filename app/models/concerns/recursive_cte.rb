# frozen_string_literal: true

module RecursiveCte
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def self_and_recursive_cte_query_arel(model_table_column, recursive_cte_column, model_ids)
    # WITH RECURSIVE "RECURSIVE_CTE" AS (
    #   SELECT "MODEL_TABLE".* FROM "MODEL_TABLE" WHERE "MODEL_TABLE"."id" IN (MODEL_IDS)
    #   UNION ALL
    #   SELECT "MODEL_TABLE".* FROM "MODEL_TABLE"
    #     INNER JOIN "RECURSIVE_CTE" ON "MODEL_TABLE"."AREL_TABLE_COLUMN" = "RECURSIVE_CTE"."RECURSIVE_CTE_COLUMN"
    # ) SELECT "RECURSIVE_CTE"."id" FROM "RECURSIVE_CTE"
    # This recursive SQL allows us to get all ancestor or descendant models
    # given a list of model ids. The method itself represents this recursive
    # CTE SQL query in arel.
    recursive_cte = Arel::Table.new(:recursive_cte)
    select_manager = Arel::SelectManager.new(ActiveRecord::Base).freeze

    non_recursive_term = select_manager.dup.tap do |m|
      m.from(arel_table)
      m.project(arel_table[Arel.star])
      m.where(arel_table[:id].in(model_ids))
    end

    recursive_term = select_manager.dup.tap do |m|
      m.from(arel_table)
      m.join(recursive_cte)
      m.on(arel_table[model_table_column].eq(recursive_cte[recursive_cte_column]))
      m.project(arel_table[Arel.star])
    end

    union = non_recursive_term.union(:all, recursive_term)
    as_statement = Arel::Nodes::As.new(recursive_cte, union)

    select_manager.dup.tap do |m|
      m.from(recursive_cte)
      m.with(:recursive, as_statement)
      m.project(recursive_cte[:id])
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
end
