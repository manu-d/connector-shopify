class ShopifyClient
  attr_reader :oauth_uid
  attr_reader :oauth_token


  def initialize(oauth_uid, oauth_token)
    @oauth_uid = oauth_uid
    @oauth_token = oauth_token
  end


  def find(external_entity_name)
    ShopifyAPI::Session.temp(@oauth_uid, @oauth_token) do
      ShopifyAPI::Product.find(:all).map { |x| x.serializable_hash }
    end
  end

  def create(external_entity_name, mapped_connec_entity)
    ShopifyAPI::Session.temp(@oauth_uid, @oauth_token) do
      element = ShopifyAPI::Product.create mapped_connec_entity
      element.id
    end
  end

  def update(external_entity_name, mapped_connec_entity)
    ShopifyAPI::Session.temp(@oauth_uid, @oauth_token) do
      ShopifyAPI::Product.create mapped_connec_entity
    end
  end
end