# frozen_string_literal: true

class AdsController < ApplicationController
  before_action :set_product, only: :create

  def new; end

  def create
    @guid = SecureRandom.uuid
    GenerateAdJob.perform_later(@guid, @product.description, *Author.where(id: params[:author_ids]))
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end
end
