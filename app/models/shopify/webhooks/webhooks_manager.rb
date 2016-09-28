module Shopify
  module Webhooks

    class WebhooksManager
      class CreationFailed < StandardError
      end

      def self.get_manager(params)
        org_uid = params.fetch(:org_uid)
        shop_name = params.fetch(:shop_name)
        token = params.fetch(:token)
        WebhooksManager.new(org_uid, shop_name, token)
      end

      def self.queue_create_webhooks(org_uid, shop_name, token)
        WebhooksCreationJob.perform_later(org_uid: org_uid, shop_name: shop_name, token: token)
      end

      def self.queue_destroy_webhooks(org_uid, shop_name, token)
        WebhooksDestructionJob.perform_later(org_uid: org_uid, shop_name: shop_name, token: token)
      end



      def initialize(org_uid, shop_name, token)
        @org_uid, @shop_name, @token = org_uid, shop_name, token
        tenant = Maestrano::Connector::Rails::Organization.find_by_uid(@org_uid).tenant
        @app_host = Maestrano[tenant].param('app_host')
      end

      def recreate_webhooks!
        destroy_webhooks
        create_webhooks
      end

      def create_webhooks
        return unless required_webhooks.present?

        with_shopify_session do
          webhooks = current_webhooks
          required_webhooks.each do |webhook|
            create_webhook(webhook) unless webhook_exists?(webhooks, webhook)
          end
        end
      end

      def destroy_webhooks
        with_shopify_session do
          current_webhooks.each do |webhook|
              ShopifyAPI::Webhook.delete(webhook.id) if webhook.address.end_with? @org_uid
            end
          end
        end

        def destroy_all_webhooks
          with_shopify_session do
            current_webhooks.all.each do |webhook|
              ShopifyAPI::Webhook.delete(webhook.id)
            end
          end
        end
      private
        def required_webhooks
          [
              {topic: 'products/create', path: 'products/create'},
              {topic: 'products/update', path: 'products/update'},
              {topic: 'orders/updated', path: 'orders/update'},
              {topic: 'customers/update', path: 'customers/update'},
          ]
        end

        def with_shopify_session
          ShopifyAPI::Session.temp(@shop_name, @token) do
            yield
          end
        end

        def webhook_address(path)
          [@app_host, 'webhooks', path, @org_uid].join('/')
        end

        def create_webhook(attributes)
          attributes.reverse_merge!(format: 'json')
          attributes[:address] = webhook_address(attributes[:path])
          webhook = ShopifyAPI::Webhook.create(attributes)
          raise CreationFailed, "could not create webhook:#{attributes}: #{webhook.errors.values.join(',')}" unless webhook.persisted?
          webhook
        end

        def webhook_exists?(webhooks, webhook)
          webhooks.any? do |x|
            x.topic == webhook[:topic] && x.address == webhook_address(webhook[:path])
          end
        end

        def current_webhooks
           #Webook.all may return nil
           ShopifyAPI::Webhook.all || []
        end
      end
  end
end
