# frozen_string_literal: true

class TicketsQuery < ApplicationQuery
  DEFAULT_STATUS = 'open'

  def call
    items = initial_relation

    items = by_status(items, params[:status])
    items = by_assignee(items, params[:assignee])
    return items.root unless params[:query]

    by_content(items, params[:query]).or(by_author_username(items, params[:query]))
  end

  private

  def by_status(items_relation, status)
    items_relation.where(status: status.presence || DEFAULT_STATUS)
  end

  def by_assignee(items_relation, assignee)
    return items_relation unless assignee

    items_relation.includes(:assignment).where(assignment: { user_id: assignee })
  end

  def by_content(items_relation, query)
    return items_relation unless query

    items_relation.where(Ticket.arel_table[:content].matches("%#{query}%"))
  end

  def by_author_username(items_relation, query)
    return items_relation unless query

    authors = Author.arel_table
    items_relation.where(
      Ticket.arel_table[:author_id].in(authors.project(authors[:id]).where(authors[:username].matches(query)))
    )
  end
end
