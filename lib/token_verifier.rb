# frozen_string_literal: true

require 'active_support/configurable'
require 'action_controller'

class TokenVerifier
  include ActiveSupport::Configurable
  include ActionController::RequestForgeryProtection

  def call(env)
    return if Rails.env.test?

    @request = ActionDispatch::Request.new(env.dup)

    raise ActionController::InvalidAuthenticityToken unless verified_request?
  end

  private

  attr_reader :request
  delegate :params, :session, to: :request
end
