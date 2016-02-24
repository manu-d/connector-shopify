class Entities::Item < Maestrano::Connector::Rails::Entity

  def connec_entity_name
    'Item'
  end

  def external_entity_name
    'Product'
  end

  def mapper_class
    ItemMapper
  end
end

class ItemMapper
  extend HashMapper
  # normalize from Connec to Shopify
  # denormalize from Shopify to Connec
  # map from (connect_field) to (shopify_field)

  map from('description'), to('body_html')
  map from('name'), to('title')
  # TODO map all variants in Shopify to a different product in connec!
  # Shopify rely on a "default Variant" name: "Tile" option1 : "Default Title"
  # map from('code'), to('variants[0]/sku')
  # map from('sale_price/net_amount'), to('variants[0]/price')
  # map from('quantity_available'), to('variants[0]/inventory_quantity')
  #
  # map from('weight'), to('variants[0]/weight')
  # map from('weight_unit'), to('variants[0]/weight_unit')


end

