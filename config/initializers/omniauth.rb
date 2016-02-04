OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :salesforce, ENV['salesforce_client_id'], ENV['salesforce_client_secret']
end