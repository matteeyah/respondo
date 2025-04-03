# frozen_string_literal: true

class OrganizationsController < ApplicationController
  include AuthorizesOrganizationMembership

  def edit
    set_page_and_extract_portion_from(current_user.organization.users)
    @organization = current_user.organization
  end

  def update
    @success = current_user.organization.update(update_params)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to settings_path }
    end
  end

  private

  def update_params
    params.require(:organization).permit(:domain, :ai_guidelines)
  end
end
