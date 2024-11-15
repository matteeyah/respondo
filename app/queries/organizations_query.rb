# frozen_string_literal: true

class OrganizationsQuery < ApplicationQuery
  def call
    by_screen_name(initial_relation, params[:query])
  end

  private

  def by_screen_name(items_relation, query)
    return items_relation unless query

    items_relation.where(Organization.arel_table[:screen_name].matches("%#{query}%"))
  end
end
