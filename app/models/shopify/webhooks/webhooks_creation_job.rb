module Shopify
  module Webhooks
    class WebhooksCreationJob < ActiveJob::Base
      def perform(params = {})
        WebhooksManager.get_manager(params).create_webhooks
      end
    end
  end

end