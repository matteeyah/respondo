# frozen_string_literal: true

class ApplicationQuery
  attr_reader :initial_relation, :params

  def initialize(initial_relation, params = {})
    @initial_relation = initial_relation
    @params = params
  end

  def call
    raise NotImplementedError
  end
end
