# typed: true
# frozen_string_literal: true

class UsersController < Users::ApplicationController
  before_action :authenticate!
  before_action :authorize!

  def edit; end
end
