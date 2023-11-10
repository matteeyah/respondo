# frozen_string_literal: true

module Mentions
  class ApplicationController < ::ApplicationController
    include AuthorizesOrganizationMembership

    before_action :set_mention

    private

    def set_mention
      @mention = Mentions.find(params[:mention_id])
    end
  end
end
