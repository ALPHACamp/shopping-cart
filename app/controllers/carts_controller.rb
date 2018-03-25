class CartsController < ApplicationController
  def show
    @cart = current_cart
    @items = current_cart.cart_items

    if session[:new_order_data].present?
      @order = Order.new(session[:new_order_data])
    else
      @order = Order.new
    end
  end
end
