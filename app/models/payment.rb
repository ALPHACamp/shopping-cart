class Payment < ApplicationRecord
  belongs_to :order

  PAYMENT_METHODS = %w[Credit WebATM ATM]
  validates_inclusion_of :payment_method, in: PAYMENT_METHODS

  after_update :update_order_status

  def self.find_and_process(params)
    data = Spgateway.decrypt(params['TradeInfo'], params['TradeSha'])

    if data
      payment = Payment.find(data['Result']['MerchantOrderNo'].to_i)
      if params['Status'] == 'SUCCESS'
        payment.paid_at = Time.now
      end
      payment.params = data
      return payment
    else
      return nil
    end
  end

  def deadline
    Date.today + 3.days
  end

  def update_order_status
    if self.paid_at
      order = self.order
      order.update(payment_status: "paid")
    end
  end
end
