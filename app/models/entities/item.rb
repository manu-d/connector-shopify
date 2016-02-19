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

  map from('code'), to('id')
  map from('description'), to('body_html')
  map from('name'), to('title')
end

