class ShopifyClient
  attr_reader :oauth_uid
  attr_reader :oauth_token

  def initialize(oauth_uid, oauth_token)
    @oauth_uid = oauth_uid
    @oauth_token = oauth_token
  end


  def find(external_entity_name, params = {})
    with_shopify_session do
      if (external_entity_name == 'Shop')
        [convert_to_hash(ShopifyAPI::Shop.current)]
      else
        find_all(get_shopify_entity_constant(external_entity_name), params).map {|x| convert_to_hash x }
      end
    end
  end

  def create(external_entity_name, mapped_connec_entity)
    element = update external_entity_name, mapped_connec_entity
    element.id
  end

  def update(external_entity_name, mapped_connec_entity)
    begin
      with_shopify_session do
        element = get_shopify_entity_constant(external_entity_name).create mapped_connec_entity
        raise "could not update Shopify entity: #{element.errors.messages}" unless element.errors.messages.empty?
        element
      end
    rescue ActiveResource::BadRequest => e
      raise 'could not update Shopify entity ' + e.message + ' , ' + e.response.body
    end

  end

  private
    def get_shopify_entity_constant(external_entity_name)
      "ShopifyAPI::#{external_entity_name}".constantize
    end

    def with_shopify_session
      ShopifyAPI::Session.temp(@oauth_uid, @oauth_token) do
        yield
      end
    end

    # shopify paginate its result
    def find_all(shopify_instance, params = {})
      params[:limit] ||= 50
      params[:page] = 1
      result = []
      begin
        entities = shopify_instance.find(:all, :params => params)
        params[:page] += 1
        result.push *(entities.to_a)
      end while entities.length == params[:limit]
      result
    end

    # ugly hack, did not find a better way to convert an entity to a  seriable hash (serializable_hash was not recursive)
    def convert_to_hash (x)
      JSON.parse(x.to_json)
    end
end