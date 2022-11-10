# frozen_string_literal: true

module WithDescendants
  extend ActiveSupport::Concern

  class_methods do
    def with_descendants_hash(*included_relations)
      tickets = all.with_descendants.includes(included_relations)
      convert_ticket_array_to_hash(tickets)
    end

    def with_descendants
      RecursiveCteQuery.new(all, model_column: :parent_id, recursive_cte_column: :id).call
    end

    private

    def convert_ticket_array_to_hash(tickets)
      {}.extend(Hashie::Extensions::DeepFind).tap do |hash|
        tickets.each do |ticket|
          # This is used instead of ticket.parent to prevent an additional DB query
          parent = tickets.find { |parent_ticket| parent_ticket.id == ticket.parent_id }
          # Either add to the ticket hash key or create a root key for the ticket
          (hash.deep_find(parent) || hash).merge!(ticket => {})
        end
      end
    end
  end

  def with_descendants_hash(*included_relations)
    Ticket.where(id:).with_descendants_hash(*included_relations)
  end
end
