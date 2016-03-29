class WebhooksController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :verify_request

  def receive
    org_uid = params[:org_uid]
    organization = Maestrano::Connector::Rails::Organization.find_by_uid(org_uid)
    if organization
      Rails.logger.debug("WebhooksController.receive with params: #{webhook_params}")
      if (params[:entity] === 'orders')
        # invoices are not sent via webhooks
        client = Maestrano::Connector::Rails::External.get_client organization
        transaction = Entities::Invoice.get_order_transaction client, webhook_params
        entities_hash = {'Order' => [webhook_params]}
        entities_hash['Transaction'] = [transaction] if transaction
      else
        entities_hash = {params[:entity].singularize.capitalize => [webhook_params]}
      end
      Maestrano::Connector::Rails::PushToConnecJob.perform_later organization, entities_hash
    else
      Rails.logger.debug('WebhooksController.receive: could not find organization: ' + org_uid)
    end
    head 200, content_type: 'application/json'
  end

  private
    def webhook_params
      params.except(:controller, :action, :type)
    end

    def webhook_type
      params[:type]
    end

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
