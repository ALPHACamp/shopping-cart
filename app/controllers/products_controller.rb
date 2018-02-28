class ProductsController < ApplicationController
  def index
    @products = Product.page(params[:page]).per(50)
  end

  def show
    @product = Product.find(params[:id])
  end

  def add_to_cart
    @product = Product.find(params[:id])
    current_cart.add_cart_item(@product)

    redirect_back(fallback_location: root_path)
  end

  def remove_from_cart
    product = Product.find(params[:id])
    cart_item = current_cart.cart_items.find_by(product_id: product)
    cart_item.destroy

    redirect_back(fallback_location: root_path)
  end
end
