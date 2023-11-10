# frozen_string_literal: true

module WithDescendants
  extend ActiveSupport::Concern

  class_methods do
    def with_descendants_hash(*included_relations)
      mention_ids = all.pluck(:id)
      mentions = unscoped.where(id: mention_ids).with_descendants.includes(included_relations)
      convert_mention_array_to_hash(mentions)
    end

    def with_descendants
      RecursiveCteQuery.new(all, model_column: :parent_id, recursive_cte_column: :id).call
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
