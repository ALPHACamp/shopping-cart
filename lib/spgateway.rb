class Spgateway

  mattr_accessor :merchant_id
  mattr_accessor :hash_key
  mattr_accessor :hash_iv
  mattr_accessor :url

  def initialize(payment)
    @payment = payment
    self.merchant_id = "MS33418458"
    self.hash_key = "DEOViIHoxZRzElSe9p14KFa8k4vx7Tfv"
    self.hash_iv = "nIxiaIldrOFR4JPe"
    self.url = "https://ccore.spgateway.com/MPG/mpg_gateway"
  end

  def generate_form_data(return_url)
    spgateway_data = {
      MerchantID: self.merchant_id,
      Version: 1.4,
      RespondType: "JSON",
      TimeStamp: @payment.created_at.to_i,
      MerchantOrderNo: "#{@payment.id}AC",
      Amt: @payment.amount,
      ItemDesc: @payment.order.name,
      ReturnURL: return_url,
      Email: @payment.order.user.email,
      LoginType: 0
    }

    spgateway_data.to_query
  end
end
