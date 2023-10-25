# frozen_string_literal: true

class OrganizationsController < ApplicationController
  include AuthorizesOrganizationMembership
  include Pagy::Backend

  def edit
    @pagy, @organization_users = pagy(current_user.organization.users)
    @organization = current_user.organization
  end

  def update
    @success = current_user.organization.update(update_params)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to settings_path }
    end
  end

  def linkedin
    @organization_account = OrganizationAccount.find_by(provider: 1)

    li = Clients::Linkedin.new(Rails.application.credentials.linkedin.client_id,
                               Rails.application.credentials.linkedin.client_secret,
                               @organization_account.token,
                               @organization_account)
    li.new_mentions(0)
  end

  private

  def organizations
    OrganizationsQuery.new(Organization.all, params.slice(:query)).call
  end

  def update_params
    params.require(:organization).permit(:domain, :ai_guidelines)
  end
end
