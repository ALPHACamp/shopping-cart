class OrdersController < ApplicationController
  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def create
    @order = current_user.orders.new(order_params)
    @order.sn = Time.now.to_i
    @order.add_order_items(current_cart)
    @order.amount = current_cart.subtotal
    if @order.save
      current_cart.destroy
      redirect_to orders_path, notice: "new order created"
    else
      @items = current_cart.cart_items
      render "carts/show"
    end
  end

  private

  def order_params
    params.require(:order).permit(:name, :phone, :address, :payment_method)
  end
end
