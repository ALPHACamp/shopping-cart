class Spgateway

  mattr_accessor :merchant_id
  mattr_accessor :hash_key
  mattr_accessor :hash_iv
  mattr_accessor :url

  def initialize(payment)
    @payment = payment

    spgateway_config = Rails.application.config_for(:spgateway)

    self.merchant_id = spgateway_config["merchant_id"]
    self.hash_key = spgateway_config["hash_key"]
    self.hash_iv = spgateway_config["hash_iv"]
    self.url = spgateway_config["url"]
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

    trade_info = self.encrypt(spgateway_data)
    trade_sha = self.class.generate_aes_sha256(trade_info)

    return {
      MerchantID: self.merchant_id,
      TradeInfo: trade_info,
      TradeSha: trade_sha,
      Version: '1.4'
    }
  end

  def self.decrypt(trade_info, trade_sha)
    return nil if self.generate_aes_sha256(trade_info) != trade_sha

    decipher = OpenSSL::Cipher::AES256.new(:CBC)
    decipher.decrypt
    decipher.padding = 0
    decipher.key = self.hash_key
    decipher.iv = self.hash_iv

    binary_encrypted = [trade_info].pack('H*') # hex to binary
    plain = decipher.update(binary_encrypted) + decipher.final

    # strip last padding
    if plain[-1] != '}'
      plain = plain[0, plain.index(plain[-1])]
    end

    return JSON.parse(plain)
  end

  def encrypt(params_data)
    cipher = OpenSSL::Cipher::AES256.new(:CBC)
    cipher.encrypt
    cipher.key = self.hash_key
    cipher.iv  = self.hash_iv
    encrypted = cipher.update(params_data.to_query) + cipher.final
    aes = encrypted.unpack('H*').first # binary 轉 hex
  end

  def self.generate_aes_sha256(trade_info)
    str = "HashKey=#{self.hash_key}&#{trade_info}&HashIV=#{self.hash_iv}"
    Digest::SHA256.hexdigest(str).upcase
  end
end
