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

  # ----------------------------------------------
  #                 General methods
  # ----------------------------------------------
  # * Discards entities that do not need to be pushed because they have not been updated since their last push
  # * Discards entities from one of the two source in case of conflict
  # * Maps not discarded entities and associates them with their idmap, or create one if there isn't any
  def consolidate_and_map_data(connec_entities, external_entities, organization, opts={})
    # group connec entities into variants
    new_connec_entities = []
    # create default value with a mutable empty array
    item_variants = Hash.new { |h, k| h[k] = [] }
    connec_entities.each do |item|
      parent_id = item['parent_item_id']
      if parent_id.nil?
        new_connec_entities.push item
      else
        item_variants[parent_id].push item
      end
    end

    new_connec_entities.each do |parent_item|
      variants = parent_item['variants'] = item_variants[parent_item['id']] || []
      parent_item['updated_at'] = [parent_item['updated_at'].to_time, variants.map { |x| x['updated_at'].to_time }].flatten!.max.iso8601
    end
    connec_entities.clear
    connec_entities.push *new_connec_entities
    super(connec_entities, external_entities, organization, opts)

  end

  def push_entities_to_connec(connec_client, mapped_external_entities_with_idmaps, organization)

    self.push_entities_to_connec_to(connec_client, mapped_external_entities_with_idmaps, self.connec_entity_name, organization)
    variants = []
    mapped_external_entities_with_idmaps.each do |product|
      parent_connect_id = product[:idmap].connec_id
      product[:entity][:variants].each do |variant|
        variant[:parent_item_id] = parent_connect_id
        idmap = Maestrano::Connector::Rails::IdMap.find_by(external_id: variant[:external_id], connec_entity: connec_entity_name.downcase, external_entity: 'variant', organization_id: organization.id)
        variants.push({entity: variant, idmap: idmap || Maestrano::Connector::Rails::IdMap.create(external_id: variant[:external_id], connec_entity: connec_entity_name, external_entity: 'variant', organization_id: organization.id)})
      end
    end
    self.push_entities_to_connec_to(connec_client, variants, self.connec_entity_name, organization)
  end

  def push_entities_to_external(external_client, mapped_connec_entities_with_idmaps, organization)
    mapped_connec_entities_with_idmaps.each do |mapped_connec_entity_with_idmap|
      mapped_connec_entity_with_idmap[:entity][:variants].each do |variant|
        idmap = Maestrano::Connector::Rails::IdMap.find_by(connec_id: variant[:connec_id], connec_entity: connec_entity_name.downcase, external_entity: 'variant', organization_id: organization.id)
        variant[:id] = idmap.external_id if idmap
      end
    end
    push_entities_to_external_to(external_client, mapped_connec_entities_with_idmaps, self.external_entity_name, organization)
  end
end

class VariantMapper
  extend HashMapper
  map from('id'), to('connec_id')
  map from('external_id'), to('id')
  map from('description'), to('option1')
  map from('name'), to('title')
  map from('parent_item_id'), to('product_id')
  map from('description'), to('body_html')

  map from('code'), to('sku')
  map from('sale_price/net_amount'), to('price')
  map from('quantity_available'), to('inventory_quantity', &:to_i)

  map from('weight'), to('weight')
  map from('weight_unit'), to('weight_unit')

end
class ItemMapper
  extend HashMapper
  # normalize from Connec to Shopify
  # denormalize from Shopify to Connec
  # map from (connect_field) to (shopify_field)

  map from('description'), to('body_html')
  map from('name'), to('title')
  map from('description'), to('body_html')
  map from('/variants'), to('/variants'), using: VariantMapper


end