class Spgateway

  mattr_accessor :merchant_id
  mattr_accessor :hash_key
  mattr_accessor :hash_iv
  mattr_accessor :url
  mattr_accessor :notify_url

  def self.setup
    yield(self)
  end

  def initialize(payment)
    @payment = payment
  end

  def generate_form_data(return_url)
    spgateway_data = {
      MerchantID: self.merchant_id,
      RespondType: "JSON",
      TimeStamp: @payment.created_at.to_i,
      Version: "1.4",
      LangType: I18n.locale.downcase, # zh-tw or en
      MerchantOrderNo: @payment.external_id,
      Amt: @payment.amount,
      ItemDesc: @payment.name,
      ReturnURL: return_url,
      NotifyURL: self.notify_url,
      Email: @payment.email,
      LoginType: 0,
      CREDIT: 0,
      WEBATM: 0,
      VACC: 0,
      CVS: 0,
      BARCODE: 0
    }

    case @payment.payment_method
      when "Credit"
        spgateway_data.merge!( :CREDIT => 1 )
      when "WebATM"
        spgateway_data.merge!( :WEBATM => 1 )
      when "ATM"
        spgateway_data.merge!( :VACC => 1, :ExpireDate => payment.deadline.strftime("%Y%m%d") )
      when "CVS"
        spgateway_data.merge!( :CVS => 1, :ExpireDate => payment.deadline.strftime("%Y%m%d") )
      when "BARCODE"
        spgateway_data.merge!( :BARCODE => 1, :ExpireDate => payment.deadline.strftime("%Y%m%d") )
    end

    Rails.logger.debug(spgateway_data)

    trade_info = self.encrypt(spgateway_data)
    trade_sha = self.class.generate_aes_sha256(trade_info)

    {
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
    decipher.key = self.hash_key
    decipher.iv = self.hash_iv

    binary_encrypted = [trade_info].pack('H*') # hex 轉 binary
    plain = decipher.update(binary_encrypted)

    # strip last padding
    if plain[-1] != '}'
      plain = plain[0, plain.index(plain[-1])]
    end

    return JSON.parse(plain)
  end

  protected

  def encrypt(params_data)
    cipher = OpenSSL::Cipher::AES256.new(:CBC)

    cipher.encrypt
    cipher.key = self.hash_key
    cipher.iv = self.hash_iv

    encrypted = cipher.update(params_data.to_query) + cipher.final

    return encrypted.unpack('H*')[0] # binary 轉 hex
  end

  def self.generate_aes_sha256(trade_info)
    str = "HashKey=#{self.hash_key}&#{trade_info}&HashIV=#{self.hash_iv}"
    Digest::SHA256.hexdigest(str).upcase
  end

end
