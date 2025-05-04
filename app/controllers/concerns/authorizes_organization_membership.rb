# frozen_string_literal: true

module AuthorizesOrganizationMembership
  extend ActiveSupport::Concern

  included do
    before_action :authorize_organization_membership!
  end

  def authorize_organization_membership!
    return if Current.user.organization

    redirect_to root_url
  end
end
