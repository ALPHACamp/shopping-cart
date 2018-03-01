class CartsController < ApplicationController
  def show
    @cart = current_cart
    @items = current_cart.cart_items
    @order = Order.new
  end
end
