class Payment < ApplicationRecord
  belongs_to :order
  after_update :update_order_status

  PAYMENT_METHODS = %w[Credit WebATM ATM CVS BARCODE]
  validates_inclusion_of :payment_method, :in => PAYMENT_METHODS
  serialize :params, JSON

  def self.find_and_process(params)
    data = Spgateway.decrypt(params['TradeInfo'], params['TradeSha'])
    if data
      payment = self.find(data['Result']['MerchantOrderNo'].to_i)
      if params['Status'] == 'SUCCESS'
        payment.paid_at = Time.now
      end
      payment.params = data
      return payment
    else
      return nil
    end
  end

  def email
    self.order.user.email
  end

  def external_id
    "#{self.id}AC#{Rails.env.upcase[0]}"
  end

  def name
    "AC商店訂單編號 #{self.order_id}"
  end

  def update_order_status
    if self.paid_at
      self.order.update( :payment_status => "paid" )
    end
  end
end
