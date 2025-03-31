# frozen_string_literal: true

module OrganizationsHelper
  def add_users_dropdown_options_for
    User.where(organization_id: nil).pluck(:id, :name)
  end
end
