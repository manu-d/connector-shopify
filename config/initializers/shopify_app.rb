ShopifyApp.configure do |config|
  config.api_key = ENV['shopify_api_id']
  config.secret =ENV['shopify_api_key']
  config.scope = "read_orders, write_orders, read_products, write_products, read_customers, write_customers"
  config.embedded_app = false
end
