# frozen_string_literal: true

class UsersController < Users::ApplicationController
  before_action :authorize!, only: [:edit]

  def edit; end
end
