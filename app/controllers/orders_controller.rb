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

      # get params string
      spgateway_data = {
        MerchantID: "MS33418458",
        Version: 1.4,
        RespondType: "JSON",
        TimeStamp: Time.now.to_i,
        MerchantOrderNo: @payment.sn,
        Amt: @order.amount,
        ItemDesc: @order.name,
        Email: @order.user.email,
        LoginType: 0
      }.to_query

      #=> "MerchantID=MS33418458&Version=1.4&RespondType=JSON&TimeStamp=1520672384&MerchantOrderNo=1520672373&Amt=10120&ItemDesc=Ellen&Email=root@example.com&LoginType=0"

      # AES encrypt

      hash_key = "DEOViIHoxZRzElSe9p14KFa8k4vx7Tfv"
      hash_iv = "nIxiaIldrOFR4JPe"

      cipher = OpenSSL::Cipher::AES256.new(:CBC)
      cipher.encrypt
      cipher.key = hash_key
      cipher.iv  = hash_iv
      encrypted = cipher.update(spgateway_data) + cipher.final
      aes = encrypted.unpack('H*').first

      #=> "e728e8d86d8a482a527aa285446617bbcf97875ef767af936ba96981e239198cafc1f9866bada57e2bee075469525a49937b056fb0523d0ce970a6747bc94b83122cd800ccb70856918fcc73fb12509debc4da2e7f010af81f4e58dfbca51f0139165c2c2d507e65ce663fd98f37a706b75ecf0000a41713124efef5098a114fe000a51b49816d4d85a9b922a5961e8f951a1adc589f378ba498efc77e05f319"

      # SHA256

      str = "HashKey=#{hash_key}&#{aes}&HashIV=#{hash_iv}"
      sha = Digest::SHA256.hexdigest(str).upcase

      # => "F2360356646949CFA34E42D07BC55E6EEB00149A18B05193872C798D7E5090C6"

      # set form instance variable
      @merchant_id = "MS33418458"
      @trade_info = aes
      @trade_sha = sha
      @version = "1.4"

      render layout: false
    end
  end

  private

  def order_params
    params.require(:order).permit(:name, :phone, :address, :payment_method)
  end

end
