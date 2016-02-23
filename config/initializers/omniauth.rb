Rails.application.config.middleware.use OmniAuth::Builder do
  provider :shopify,
   ENV['shopify_api_id'],
   ENV['shopify_api_key'],
   :scope => 'write_orders,write_products,write_customers'
end
