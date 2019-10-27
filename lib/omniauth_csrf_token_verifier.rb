# typed: true
# frozen_string_literal: true

require 'active_support/configurable'
require 'action_controller'

class OmniauthCsrfTokenVerifier
  include ActiveSupport::Configurable
  include ActionController::RequestForgeryProtection

  def call(env)
    @request = ActionDispatch::Request.new(env.dup)

    raise ActionController::InvalidAuthenticityToken unless verified_request?
  end

  private

  attr_reader :request
  delegate :params, :session, to: :request
end
