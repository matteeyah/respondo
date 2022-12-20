# frozen_string_literal: true

module AuthorizesBrandMembership
  extend ActiveSupport::Concern

  included do
    before_action :authorize_brand_membership!
  end

  def authorize_brand_membership!
    return if current_user.brand

    redirect_to root_url
  end
end
