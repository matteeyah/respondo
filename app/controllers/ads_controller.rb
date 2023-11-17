# frozen_string_literal: true

class AdsController < ApplicationController
  def new; end

  def create
    @guid = SecureRandom.uuid
    GenerateAdJob.perform_later(@guid, params[:product_description], Author.find_by(id: params[:author_ids]))
  end
end
