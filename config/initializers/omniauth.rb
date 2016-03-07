Rails.application.config.middleware.use OmniAuth::Builder do
  provider :shopify,
   ENV['shopify_api_id'],
   ENV['shopify_api_key'],
   :scope => 'write_orders,write_products,write_customers',
   :on_failure => OauthController.action(:oauth_failure),
   :failure_raise_out_environments => []
end
OmniAuth.config.on_failure = OauthController.action(:oauth_failure)
OmniAuth.config.failure_raise_out_environments = []
