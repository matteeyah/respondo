# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authentication

  etag { Rails.application.importmap.digest(resolver: helpers) if request.format&.html? }

  protect_from_forgery with: :exception
end
