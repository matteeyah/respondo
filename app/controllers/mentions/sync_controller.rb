# frozen_string_literal: true

module Mentions
  class SyncController < ::ApplicationController
    include AuthorizesOrganizationMembership

    def create
      LoadNewMentionsJob.perform_later(current_user.organization)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to mentions_path }
      end
    end
  end
end
