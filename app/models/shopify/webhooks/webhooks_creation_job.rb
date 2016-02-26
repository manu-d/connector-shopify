module Shopify
  module Webhooks
    class WebhooksCreationJob < ActiveJob::Base
      def get_manager(params)
        org_uid = params.fetch(:org_uid)
        shop_name = params.fetch(:shop_name)
        token = params.fetch(:token)
        WebhooksManager.new(org_uid, shop_name, token)
      end
      def perform(params = {})
        get_manager(params).create_webhooks
      end
    end
  end

end