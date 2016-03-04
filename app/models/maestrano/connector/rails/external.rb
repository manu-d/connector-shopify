class Maestrano::Connector::Rails::External
  include Maestrano::Connector::Rails::Concerns::External

  def self.external_name
    'Shopify'
  end

  def self.get_client(organization)
    # Create New Client
    ShopifyClient.new organization.oauth_uid, organization.oauth_token
  end

end