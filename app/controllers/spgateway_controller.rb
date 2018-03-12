class SpgatewayController < ActionController::Base

  def return
    trade_info = spagatway_params['TradeInfo']
    trade_sha = spagatway_params['TradeSha']

    data = Spgateway.decrypt(trade_info, trade_sha)

    if data
      payment = Payment.find(data['Result']['MerchantOrderNo'].to_i)
      if params['Status'] == 'SUCCESS'
        payment.paid_at = Time.now
      end
      payment.params = data
    end

    if payment&.save
      order = payment.order
      order.update(payment_status: "paid")
      # send paid email
      flash[:notice] = "#{payment.sn} paid"
    else
      flash[:alert] = "Something wrong!!!"
    end

    redirect_to orders_path
  end

  private

  def spagatway_params
    params.slice("Status", "MerchantID", "Version", "TradeInfo", "TradeSha")
  end
end
