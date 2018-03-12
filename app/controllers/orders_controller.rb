class OrdersController < ApplicationController
  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def create
    # manually check if user logged in
    if current_user.nil?
      # store order data in session so we can retrieve it later
      session[:new_order_data] = params[:order]
      # redirect to devise login page
      redirect_to new_user_session_path
    else
      @order = current_user.orders.new(order_params)
      @order.sn = Time.now.to_i
      @order.add_order_items(current_cart)
      @order.amount = current_cart.subtotal
      if @order.save
        current_cart.destroy
        session.delete(:new_order_data)
        UserMailer.notify_order_create(@order).deliver_now!
        redirect_to orders_path, notice: "new order created"
      else
        @items = current_cart.cart_items
        render "carts/show"
      end
    end
  end

  def update
    @order = current_user.orders.find(params[:id])
    if @order.shipping_status == "not_shipped"
      @order.shipping_status = "cancelled"
      @order.save
      redirect_to orders_path, alert: "order##{@order.sn} cancelled."
    end
  end

  def checkout_spgateway
    @order = current_user.orders.find(params[:id])
    if @order.payment_status != "not_paid"
      flash[:alert] = "Order has been paid."
      redirect_to orders_path
    else
      @payment = Payment.create!(
        sn: Time.now.to_i,
        order_id: @order.id,
        amount: @order.amount
      )

      spgateway_data = Spgateway.new(@payment).generate_form_data(spgateway_return_url)

      @merchant_id = spgateway_data[:MerchantID]
      @trade_info = spgateway_data[:TradeInfo]
      @trade_sha = spgateway_data[:TradeSha]
      @version = spgateway_data[:Version]

      render layout: false
    end
  end

  private

  def order_params
    params.require(:order).permit(:name, :phone, :address, :payment_method)
  end

end
