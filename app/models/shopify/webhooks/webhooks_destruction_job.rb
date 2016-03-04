module Shopify
  module Webhooks
    class WebhooksDestructionJob < ActiveJob::Base
      def perform(params = {})
        WebhooksManager.get_manager(params).destroy_webhooks
      end
    end
  end

end
