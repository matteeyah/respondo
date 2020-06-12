# frozen_string_literal: true

class BrandsQuery
  attr_reader :initial_relation, :params

  def initialize(initial_relation = Brand.all, params = {})
    @initial_relation = initial_relation
    @params = params
  end

  def call
    by_screen_name(@initial_relation, @params[:query])
  end

  private

  def by_screen_name(items_relation, query)
    return items_relation unless query

    items_relation.where(Brand.arel_table[:screen_name].matches("%#{query}%"))
  end
end
