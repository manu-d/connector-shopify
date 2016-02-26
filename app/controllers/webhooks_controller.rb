class WebhooksController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :verify_request

  def receive
    job_args = {shop_domain: shop_domain, webhook: webhook_params}
    p "WebhooksController:#{shop_domain}, #{webhook_params}"
    head :no_content
  end

  private

  def webhook_params
    params.except(:controller, :action, :type)
  end


  def webhook_type
    params[:type]
  end


  private

  def verify_request
    data = request.raw_post
    return head :unauthorized unless hmac_valid?(data)
  end

  def hmac_valid?(data)
    secret = ENV['shopify_api_key']
    digest = OpenSSL::Digest.new('sha256')
    ActiveSupport::SecurityUtils.variable_size_secure_compare(
        shopify_hmac,
        Base64.encode64(OpenSSL::HMAC.digest(digest, secret, data)).strip
    )
  end

  def shop_domain
    request.headers['HTTP_X_SHOPIFY_SHOP_DOMAIN']
  end

  def shopify_hmac
    request.headers['HTTP_X_SHOPIFY_HMAC_SHA256']
  end
end
