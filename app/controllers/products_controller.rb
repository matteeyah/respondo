# frozen_string_literal: true

class ProductsController < ApplicationController
  include AuthorizesOrganizationMembership

  def index
    @products = Product.where(organization_id: current_user.organization_id)
  end

  def new
    @product = Product.new
  end

  def edit
    @product = Product.find_by(id: params[:id])
  end

  def create
    @product = Product.new(**product_params, organization_id: current_user.organization_id)

    @product.save!
    redirect_to products_path
  end

  def update
    @product = Product.find_by(id: params[:id])

    @product.update(product_params)
    redirect_to products_path
  end

  def destroy
    @product = Product.find_by(id: params[:id])

    @product.destroy!
    redirect_to products_path
  end

  private

  def product_params
    params.require(:product).permit(:name, :description)
  end
end
