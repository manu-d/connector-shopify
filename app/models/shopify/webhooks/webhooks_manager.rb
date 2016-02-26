module Shopify
  module Webhooks
    class WebhooksManager
      class CreationFailed < StandardError;
      end

      def self.queue_create_webhooks(org_uid, shop_name, token)
        WebhooksCreationJob.perform_later(org_uid: org_uid, shop_name: shop_name, token: token)
      end

      def self.queue_destroy_webhooks(org_uid, shop_name, token)
        WebhooksDestructionJob.perform_later(org_uid: org_uid, shop_name: shop_name, token: token)
      end

      def initialize(org_uid, shop_name, token)
        @org_uid, @shop_name, @token = org_uid, shop_name, token
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
            ShopifyAPI::Webhook.delete(webhook.id) if webhook.address.end_with? @org_uid
          end
        end
      end

      private


      def required_webhooks
        app_host = Maestrano['default'].param('app_host')
        [
            {topic: 'products/create', path: 'products/create'},
            {topic: 'products/update', path: 'products/update'},
            {topic: 'products/delete', path: 'products/delete'},
            {topic: 'orders/create', path: 'products/create'},
            # For only that one, it is 'update*d*'
            {topic: 'orders/updated', path: 'orders/update'},
            {topic: 'orders/delete', path: 'orders/delete'},
            {topic: 'customers/create', path: 'customers/create'},
            {topic: 'customers/update', path: 'customers/update'},
            {topic: 'customers/delete', path: 'customers/delete'}
        ]
      end

      def with_shopify_session
        ShopifyAPI::Session.temp(@shop_name, @token) do
          yield
        end
      end

      def webhook_address(path)
        [Maestrano['default'].param('app_host'), 'webhooks', path, @org_uid].join('/')
      end

      def create_webhook(attributes)
        attributes.reverse_merge!(format: 'json')
        attributes[:address] = webhook_address(attributes[:path])
        webhook = ShopifyAPI::Webhook.create(attributes)
        raise CreationFailed, "could not create webhook:#{attributes}: #{webhook.errors.values.join(',')}" unless webhook.persisted?
        webhook
      end

      def webhook_exists?(webhook)
        current_webhooks.any? do |x|
          x.topic == webhook[:topic] && x.address == webhook_address(webhook[:path])
        end
      end

      def current_webhooks
        @current_webhooks ||= ShopifyAPI::Webhook.all
      end
    end
  end

end

