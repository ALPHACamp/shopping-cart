require 'spgateway'
spgateway_config = Rails.application.config_for(:spgateway)

Spgateway.setup do |config|
  config.merchant_id = spgateway_config["merchant_id"]
  config.hash_key = spgateway_config["hash_key"]
  config.hash_iv = spgateway_config["hash_iv"]
  config.url = spgateway_config["url"]
  config.notify_url = spgateway_config["notify_url"]
end
