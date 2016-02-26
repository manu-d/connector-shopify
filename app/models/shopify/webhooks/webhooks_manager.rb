module Shopify
  module Webhooks
    class WebhooksManager
      class CreationFailed < StandardError;
      end


      def self.queue_create_webhooks(shop_name, token)
        WebhooksCreationJob.perform_later(shop_name: shop_name, token: token)
      end

      def self.queue_destroy_webhooks(shop_name, token)
        WebhooksDestructionJob.perform_later(shop_name: shop_name, token: token)
      end

      def initialize(shop_name, token)
        @shop_name, @token = shop_name, token
      end

      def recreate_webhooks!
        destroy_webhooks
        create_webhooks
      end

      def create_webhooks
        return unless required_webhooks.present?

        with_shopify_session do
          required_webhooks.each do |webhook|
            create_webhook(webhook) unless webhook_exists?(webhook)
          end
        end
      end

      def destroy_webhooks
        with_shopify_session do
          ShopifyAPI::Webhook.all.each do |webhook|
            ShopifyAPI::Webhook.delete(webhook.id)
          end
        end
        @current_webhooks = nil
      end

      private


      def required_webhooks
        app_host = Maestrano['default'].param('app_host')
        [
            {topic: 'products/create', address: app_host + '/webhooks/products_create'},
            {topic: 'products/update', address: app_host + '/webhooks/products_update'},
            {topic: 'products/delete', address: app_host + '/webhooks/products_delete'}
        ]
      end

      def with_shopify_session
        ShopifyAPI::Session.temp(@shop_name, @token) do
          yield
        end
      end

      def create_webhook(attributes)
        attributes.reverse_merge!(format: 'json')
        webhook = ShopifyAPI::Webhook.create(attributes)
        raise CreationFailed unless webhook.persisted?
        webhook
      end

      def webhook_exists?(webhook)
        current_webhooks.any? do |x|
          x.topic == webhook[:topic] && x.address == webhook[:address]
        end
      end

      def current_webhooks
        @current_webhooks ||= ShopifyAPI::Webhook.all
      end
    end
  end

end

