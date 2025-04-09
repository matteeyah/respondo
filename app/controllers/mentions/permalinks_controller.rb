module Mentions
  class PermalinksController < ApplicationController
    def show
      redirect_to @mention.external_link, allow_other_host: true
    end
  end
end
