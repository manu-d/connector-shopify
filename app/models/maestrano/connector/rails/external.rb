class Maestrano::Connector::Rails::External
  include Maestrano::Connector::Rails::Concerns::External

  # Return an array of all the entities that the connector can synchronize
  # If you add new entities, you need to generate
  # a migration to add them to existing organizations
  def self.entities_list
    %w(company item person financial)
  end

  def self.create_account_link(organization = nil)
    'https://www.shopify.com/?ref=maestrano'
  end

  def self.external_name
    'Shopify'
  end

  def self.get_client(organization)
    # Create New Client
    ShopifyClient.new organization.oauth_uid, organization.oauth_token
  end
end
