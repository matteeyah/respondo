# frozen_string_literal: true

class TicketsQuery < ApplicationQuery
  DEFAULT_STATUS = 'open'

  def call # rubocop:todo Metrics/AbcSize
    items = initial_relation

    items = by_status(items, params[:status])
    items = by_assignee(items, params[:assignee])
    items = by_tag(items, params[:tag])
    items = by_author(items, params[:author])
    items = by_content(items, params[:content])

    items.root
  end

  private

  def by_status(items_relation, status)
    items_relation.where(status: status.presence || DEFAULT_STATUS)
  end

  def by_assignee(items_relation, assignee)
    return items_relation unless assignee

    items_relation.includes(:assignment).where(assignment: { user_id: assignee })
  end

  def by_tag(items_relation, tag)
    return items_relation unless tag

    items_relation.tagged_with(tag)
  end

  def by_author(items_relation, author)
    return items_relation unless author

    items_relation.includes(:author).where(author: { username: author })
  end

  def by_content(items_relation, content)
    return items_relation unless content

    items_relation.where(Ticket.arel_table[:content].matches("%#{content}%"))
  end
end
