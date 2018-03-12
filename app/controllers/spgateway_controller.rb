class SpgatewayController < ActionController::Base
  def return
    result = nil
    ActiveRecord::Base.transaction do
      @payment = Payment.find_and_process(spagatway_params)
      result = @payment.save
    end

    unless result
      flash[:alert] = "不要HACK我啦~~~"
    end

    if @payment.paid_at
     # send paid email
    end

    redirect_to orders_path, notice: "#{@payment.sn} paid"
  end

  def notify
    result = nil
    ActiveRecord::Base.transaction do
      @payment = Payment.find_and_process(spagatway_params)
      result = @payment.save
    end

    if result
      render :text => "1|OK"
    else
      render :text => "0|ErrorMessage"
    end
  end

  private

  def spagatway_params
    params.slice("Status", "MerchantID", "Version", "TradeInfo", "TradeSha")
  end
end
