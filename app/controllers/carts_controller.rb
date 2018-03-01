class CartsController < ApplicationController
  def show
    @cart = current_cart
    @items = current_cart.cart_items
  end
end
