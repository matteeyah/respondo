# frozen_string_literal: true

class Mention
  module WithDescendants
    extend ActiveSupport::Concern

    class_methods do
      def with_descendants_hash(*included_relations)
        mention_ids = all.pluck(:id)
        mentions = unscoped.where(id: mention_ids).with_descendants.includes(included_relations)
        convert_mention_array_to_hash(mentions)
      end

      # WITH RECURSIVE "RECURSIVE_CTE" AS (
      #   SELECT "MODEL_TABLE".* FROM "MODEL_TABLE" WHERE "MODEL_TABLE"."id" IN (MODEL_IDS)
      #   UNION ALL
      #   SELECT "MODEL_TABLE".* FROM "MODEL_TABLE"
      #     INNER JOIN "RECURSIVE_CTE" ON "MODEL_TABLE"."MODEL_TABLE_COLUMN" = "RECURSIVE_CTE"."RECURSIVE_CTE_COLUMN"
      # ) SELECT "RECURSIVE_CTE"."id" FROM "RECURSIVE_CTE"
      # This recursive SQL allows us to get all ancestor or descendant models
      # given a list of model ids. The method itself represents this recursive
      # CTE SQL query in arel.
      def with_descendants
        arel_table = all.klass.arel_table
        model_ids = all.select(:id).arel
        model_table_column = :parent_id
        recursive_cte_column = :id

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

        all.klass.unscoped.where(arel_table[:id].in(query))
      end

      private

      def convert_mention_array_to_hash(mentions)
        {}.extend(Hashie::Extensions::DeepFind).tap do |hash|
          mentions.each do |mention|
            # This is used instead of mention.parent to prevent an additional DB query
            parent = mentions.find { |parent_mention| parent_mention.id == mention.parent_id }
            # Either add to the mention hash key or create a root key for the mention
            (hash.deep_find(parent) || hash).merge!(mention => {})
          end
        end
      end
    end

    def with_descendants_hash(*)
      Mention.where(id:).with_descendants_hash(*)
    end
  end
end
