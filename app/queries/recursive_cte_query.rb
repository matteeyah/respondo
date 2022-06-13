# frozen_string_literal: true

class RecursiveCteQuery < ApplicationQuery
  # WITH RECURSIVE "RECURSIVE_CTE" AS (
  #   SELECT "MODEL_TABLE".* FROM "MODEL_TABLE" WHERE "MODEL_TABLE"."id" IN (MODEL_IDS)
  #   UNION ALL
  #   SELECT "MODEL_TABLE".* FROM "MODEL_TABLE"
  #     INNER JOIN "RECURSIVE_CTE" ON "MODEL_TABLE"."MODEL_TABLE_COLUMN" = "RECURSIVE_CTE"."RECURSIVE_CTE_COLUMN"
  # ) SELECT "RECURSIVE_CTE"."id" FROM "RECURSIVE_CTE"
  # This recursive SQL allows us to get all ancestor or descendant models
  # given a list of model ids. The method itself represents this recursive
  # CTE SQL query in arel.
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def call
    arel_table = initial_relation.klass.arel_table
    model_ids = initial_relation.select(:id).arel
    model_table_column = params[:model_column]
    recursive_cte_column = params[:recursive_cte_column]

    recursive_cte = Arel::Table.new(:recursive_cte)
    select_manager = Arel::SelectManager.new(arel_table).freeze

    non_recursive_term = select_manager.dup.tap do |m|
      m.project(arel_table[Arel.star])
      m.where(arel_table[:id].in(model_ids))
    end

    recursive_term = select_manager.dup.tap do |m|
      m.join(recursive_cte)
      m.on(arel_table[model_table_column].eq(recursive_cte[recursive_cte_column]))
      m.project(arel_table[Arel.star])
    end

    union = non_recursive_term.union(:all, recursive_term)
    as_statement = Arel::Nodes::As.new(recursive_cte, union)

    query = Arel::SelectManager.new(recursive_cte).tap do |m|
      m.with(:recursive, as_statement)
      m.project(recursive_cte[:id])
    end

    initial_relation.klass.unscoped.where(arel_table[:id].in(query))
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
end
